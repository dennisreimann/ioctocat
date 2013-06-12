//
//  NSMutableAttributedString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "GHFMarkdown.h"
#import "GHFMarkdown+Private.h"


@implementation NSMutableAttributedString (GHFMarkdown)

+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString {
    return [self mutableAttributedStringFromGHFMarkdown:markdownString contextRepoId:nil attributes:nil];
}

+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId {
    return [self mutableAttributedStringFromGHFMarkdown:markdownString contextRepoId:contextRepoId attributes:nil];
}

+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes {
    if (!markdownString) return nil;
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] initWithString:markdownString attributes:attributes];
    NSMutableString *string = output.mutableString;
    NSDictionary *codeBlocks = [string extractAndSubstituteGHFMarkdownCodeBlocks];
    [output substituteGHFMarkdownLinksWithContextRepoId:contextRepoId];
    [output substituteGHFMarkdownHeadlines];
    [output substituteGHFMarkdownTasks];
    [output substitutePattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines) addAttributes:@{@"GHFMarkdown_Quote": @YES}];
    [output substitutePattern:GHFMarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive) addAttributes:@{@"GHFMarkdown_BoldItalic": @YES}];
    [output substitutePattern:GHFMarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive) addAttributes:@{@"GHFMarkdown_Bold": @YES}];
    [output substitutePattern:GHFMarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive) addAttributes:@{@"GHFMarkdown_Italic": @YES}];
    [output substitutePattern:GHFMarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive) addAttributes:@{@"GHFMarkdown_CodeInline": @YES}];
    [string insertSubstitutedGHFMarkdownCodeBlocks:codeBlocks];
    [output substitutePattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) addAttributes:@{@"GHFMarkdown_CodeBlock": @YES}];
    return output;
}

- (void)applyAttributes:(NSDictionary *)attributes {
    NSRange range = NSMakeRange(0, self.length);
    [attributes enumerateKeysAndObjectsUsingBlock:^(id attributeKey, id attributeValues, BOOL *stop) {
        [self enumerateAttribute:attributeKey inRange:range options:NULL usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) [self addAttributes:attributeValues range:range];
        }];
    }];
}

- (void)substituteGHFMarkdownLinksWithContextRepoId:(NSString *)contextRepoId {
    NSMutableString *string = self.mutableString;
    NSArray *links = [string linksFromGHFMarkdownWithContextRepoId:contextRepoId];
    if (links.count) {
        NSEnumerator *enumerator = [links reverseObjectEnumerator];
        for (NSDictionary *link in enumerator) {
            NSRange range = [link[@"range"] rangeValue];
            NSString *title = link[@"title"];
            NSURL *url = link[@"url"];
            if (url) [self addAttributes:@{@"GHFMarkdown_Link": url} range:range];
            [string replaceCharactersInRange:range withString:title];
        }
    }
}

- (void)substituteGHFMarkdownTasks {
    NSMutableString *string = self.mutableString;
    NSArray *tasks = [string tasksFromGHFMarkdown];
    if (tasks.count) {
        NSEnumerator *enumerator = [tasks reverseObjectEnumerator];
        for (NSDictionary *task in enumerator) {
            NSRange range = [task[@"range"] rangeValue];
            NSRange markRange = [task[@"markRange"] rangeValue];
            NSNumber *checked = task[@"checked"];
            BOOL done = [checked boolValue];
            NSString *mark = done ? @"\U00002611" : @"\U000025FB";
            [self addAttributes:@{@"GHFMarkdown_Task": checked} range:range];
            [string replaceCharactersInRange:markRange withString:mark];
        }
    }
}

- (void)substituteGHFMarkdownHeadlines {
    NSMutableString *string = self.mutableString;
    NSArray *headlines = [string headlinesFromGHFMarkdown];
    if (headlines.count) {
        NSEnumerator *enumerator = [headlines reverseObjectEnumerator];
        for (NSDictionary *headline in enumerator) {
            NSRange range = [headline[@"range"] rangeValue];
            NSString *title = headline[@"title"];
            NSNumber *level = headline[@"level"];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[level, @YES] forKeys:@[@"GHFMarkdown_Headline", [NSString stringWithFormat:@"GHFMarkdown_Headline%d", [level integerValue]]]];
            [self addAttributes:attributes range:range];
            [string replaceCharactersInRange:range withString:title];
        }
    }
}

// Performs substitution in the given pattern and adds the attributes to the resulting substitution.
// I.e. you can use this to remove the stars/underscores surrounding bold and italic words.
// The substitution pattern must have either one or two matches. In case it has two, it uses the first
// match to replace its content with the content of the seconds match. If there is only one match, the
// whole match will be replaced by the matched content.
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options addAttributes:(NSDictionary *)attributes {
    NSMutableString *string = self.mutableString;
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
            textRange = NSMakeRange(substituteRange.location, text.length);
            [self addAttributes:attributes range:textRange];
        }
    }
}

@end