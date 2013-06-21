//
//  NSMutableString_GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "GHFMarkdown.h"
#import "GHFMarkdown_Private.h"


@implementation NSMutableString (GHFMarkdown)

- (void)ghf_substituteGHFMarkdownHeadlines {
    NSArray *headlines = [self ghf_headlinesFromGHFMarkdown];
    if (headlines.count) {
        NSEnumerator *enumerator = [headlines reverseObjectEnumerator];
        for (NSDictionary *headline in enumerator) {
            NSRange headRange = [headline[@"range"] rangeValue];
            NSString *title = headline[@"title"];
            [self replaceCharactersInRange:headRange withString:title];
        }
    }
}

- (void)ghf_substituteGHFMarkdownLinks {
    NSArray *links = [self ghf_linksFromGHFMarkdownLinks];
    if (links.count) {
        NSEnumerator *enumerator = [links reverseObjectEnumerator];
        for (NSDictionary *link in enumerator) {
            NSRange range = [link[@"range"] rangeValue];
            NSString *title = link[@"title"];
            [self replaceCharactersInRange:range withString:title];
        }
        // perform recursive link substitution to get image links
        [self ghf_substituteGHFMarkdownLinks];
    }
}

- (void)ghf_substituteGHFMarkdownTasks {
    NSArray *tasks = [self ghf_tasksFromGHFMarkdown];
    if (tasks.count) {
        NSEnumerator *enumerator = [tasks reverseObjectEnumerator];
        for (NSDictionary *task in enumerator) {
            NSRange markRange = [task[@"markRange"] rangeValue];
            BOOL checked = [task[@"checked"] boolValue];
            NSString *mark = checked ? @"[x]" : @"[ ]";
            [self replaceCharactersInRange:markRange withString:mark];
        }
    }
}

- (void)ghf_substituteGHFMarkdownQuotes {
    NSArray *quotes = [self ghf_quotesFromGHFMarkdown];
    if (quotes.count) {
        NSEnumerator *enumerator = [quotes reverseObjectEnumerator];
        for (NSDictionary *quote in enumerator) {
            NSRange newlinesBeforeRange = [quote[@"newlinesBeforeRange"] rangeValue];
            NSRange newlinesAfterRange = [quote[@"newlinesAfterRange"] rangeValue];
            // take into account the hack in which ghf_quotesFromGHFMarkdown
            // appends some extra newlines at the end of the string to
            // find a quote at the end of the original string
            BOOL isAppendedNewlines = newlinesAfterRange.location == self.length;
            if (newlinesAfterRange.length == 1 && !isAppendedNewlines) {
                [self replaceCharactersInRange:newlinesAfterRange withString:GHFMarkdownQuoteNewlinePadding];
            }
            if (newlinesBeforeRange.length == 1) {
                [self replaceCharactersInRange:newlinesBeforeRange withString:GHFMarkdownQuoteNewlinePadding];
            }
        }
    }
}

// Performs substitution in the given pattern.
// I.e. you can use this to remove the stars/underscores surrounding bold and italic words.
// The substitution pattern must have either one or two matches. In case it has two, it uses the first
// match to replace its content with the content of the seconds match. If there is only one match, the
// whole match will be replaced by the matched content.
- (void)ghf_substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSMutableString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:options error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (matches.count) {
        NSEnumerator *enumerator = [matches reverseObjectEnumerator];
        for (NSTextCheckingResult *match in enumerator) {
            BOOL hasSubstitutionRange = match.numberOfRanges > 2;
            NSRange substituteRange = hasSubstitutionRange ? [match rangeAtIndex:1] : match.range;
            NSRange textRange = hasSubstitutionRange ? [match rangeAtIndex:2] : [match rangeAtIndex:1];
            NSString *text = [string substringWithRange:textRange];
            [string replaceCharactersInRange:substituteRange withString:text];
        }
    }
}

- (void)ghf_substituteGHFMarkdown {
    NSDictionary *codeBlocks = [self ghf_extractAndSubstituteGHFMarkdownCodeBlocks];
    [self ghf_substituteGHFMarkdownLinks];
    [self ghf_substituteGHFMarkdownTasks];
    [self ghf_substituteGHFMarkdownHeadlines];
    [self ghf_substitutePattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines)];
    [self ghf_substitutePattern:GHFMarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive)];
    [self ghf_substitutePattern:GHFMarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive)];
    [self ghf_substitutePattern:GHFMarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive)];
    [self ghf_substitutePattern:GHFMarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive)];
    [self ghf_insertSubstitutedGHFMarkdownCodeBlocks:codeBlocks];
    [self ghf_substitutePattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators)];
}

- (NSDictionary *)ghf_extractAndSubstituteGHFMarkdownCodeBlocks {
    NSMutableString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableDictionary *codeBlocks = [NSMutableDictionary dictionaryWithCapacity:matches.count];
    if (matches.count) {
        NSEnumerator *enumerator = [matches reverseObjectEnumerator];
        for (NSTextCheckingResult *match in enumerator) {
            NSString *text = [string substringWithRange:match.range];
            NSString *key = GHFMarkdownMD5(text);
            NSString *substitute = [NSString stringWithFormat:GHFMarkdownSubstitutionFormat, key];
            [string replaceCharactersInRange:match.range withString:substitute];
            [codeBlocks setObject:text forKey:key];
        }
    }
    return codeBlocks;
}

- (void)ghf_insertSubstitutedGHFMarkdownCodeBlocks:(NSDictionary *)codeBlocks {
    NSMutableString *string = self;
    [codeBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *substitute = [NSString stringWithFormat:GHFMarkdownSubstitutionFormat, key];
        [string replaceOccurrencesOfString:substitute withString:obj options:NULL range:NSMakeRange(0, string.length)];
    }];
}

@end