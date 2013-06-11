//
//  NSMutableString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSMutableString+GHFMarkdown.h"
#import "NSString+GHFMarkdown.h"

@implementation NSMutableString (GHFMarkdown)

- (void)substituteGHFMarkdownLinks {
    NSArray *links = [self linksFromGHFMarkdownLinks];
    if (links.count) {
        NSEnumerator *enumerator = [links reverseObjectEnumerator];
        for (NSDictionary *link in enumerator) {
            NSRange range = [link[@"range"] rangeValue];
            NSString *title = link[@"title"];
            [self replaceCharactersInRange:range withString:title];
        }
    }
}

- (void)substituteGHFMarkdownTasks {
    NSArray *tasks = [self tasksFromGHFMarkdown];
    if (tasks.count) {
        NSEnumerator *enumerator = [tasks reverseObjectEnumerator];
        for (NSDictionary *task in enumerator) {
            NSRange markRange = [task[@"markRange"] rangeValue];
            NSString *mark = task[@"mark"];
            [self replaceCharactersInRange:markRange withString:mark];
        }
    }
}

- (void)substituteGHFMarkdownHeadlines {
    NSArray *headlines = [self headlinesFromGHFMarkdown];
    if (headlines.count) {
        NSEnumerator *enumerator = [headlines reverseObjectEnumerator];
        for (NSDictionary *headline in enumerator) {
            NSRange headRange = [headline[@"range"] rangeValue];
            NSString *title = headline[@"title"];
            [self replaceCharactersInRange:headRange withString:title];
        }
    }
}

// Performs substitution in the given pattern.
// I.e. you can use this to remove the stars/underscores surrounding bold and italic words.
// The substitution pattern must have either one or two matches. In case it has two, it uses the first
// match to replace its content with the content of the seconds match. If there is only one match, the
// whole match will be replaced by the matched content.
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSMutableString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:options error:NULL];
    NSArray *matches = matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
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

- (void)substituteGHFMarkdown {
    [self substituteGHFMarkdownLinks];
    [self substituteGHFMarkdownTasks];
    [self substituteGHFMarkdownHeadlines];
    [self substitutePattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines)];
    [self substitutePattern:GHFMarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive)];
    [self substitutePattern:GHFMarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive)];
    [self substitutePattern:GHFMarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive)];
    [self substitutePattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators)];
    [self substitutePattern:GHFMarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive)];
}

@end