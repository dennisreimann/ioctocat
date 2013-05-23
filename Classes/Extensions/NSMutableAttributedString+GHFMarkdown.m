//
//  NSMutableAttributedString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSMutableAttributedString+GHFMarkdown.h"

@implementation NSMutableAttributedString (GHFMarkdown)

static NSString *const MarkdownHeadlineRegex = @"^(#{1,6})\\s++(.+)$";

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

- (void)substituteHeadlinesWithBaseFont:(UIFont *)baseFont {
    NSMutableString *string = self.mutableString;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownHeadlineRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines) error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (matches.count) {
        NSRegularExpression *endRegex = [[NSRegularExpression alloc] initWithPattern:@"\\s+#{1,6}\\s*$" options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines) error:NULL];
        NSEnumerator *enumerator = [matches reverseObjectEnumerator];
        CGFloat baseSize = baseFont.pointSize;
        CTFontRef baseRef = CTFontCreateWithName((__bridge CFStringRef)baseFont.fontName, baseSize, NULL);
        for (NSTextCheckingResult *match in enumerator) {
            NSRange headRange = [match rangeAtIndex:1];
            NSRange textRange = [match rangeAtIndex:2];
            CGFloat headSize = headSize = baseSize + (6 - headRange.length);
            CTFontRef headRef = headRef = CTFontCreateCopyWithSymbolicTraits(baseRef, headSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(headRef) forKey:(NSString *)kCTFontAttributeName];
            NSString *text = [string substringWithRange:textRange];
            NSArray *endMatches = [endRegex matchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
            if (endMatches.count == 1) {
                text = [text substringWithRange:NSMakeRange(0, text.length - [(NSTextCheckingResult *)endMatches[0] rangeAtIndex:0].length)];
            }
            [string replaceCharactersInRange:match.range withString:text];
            textRange = NSMakeRange(match.range.location, text.length);
            [self addAttributes:attributes range:textRange];
        }
    }
}

@end