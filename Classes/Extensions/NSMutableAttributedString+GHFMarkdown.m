//
//  NSMutableAttributedString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import "NSMutableAttributedString+GHFMarkdown.h"

@implementation NSMutableAttributedString (GHFMarkdown)

- (void)substitutePattern:(NSString *)pattern andAddAttributes:(NSDictionary *)attributes {
    NSMutableString *string = self.mutableString;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) error:NULL];
    NSArray *matches = matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (matches.count) {
        NSEnumerator *enumerator = [matches reverseObjectEnumerator];
        for (NSTextCheckingResult *match in enumerator) {
            NSRange textRange = [match rangeAtIndex:1];
            NSString *text = [string substringWithRange:textRange];
            [string replaceCharactersInRange:match.range withString:text];
            textRange = NSMakeRange(match.range.location, text.length);
            [self addAttributes:attributes range:textRange];
        }
    }
}

@end