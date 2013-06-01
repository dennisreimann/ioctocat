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

// Performs substitution in the given pattern and adds the attributes to the resulting substitution.
// I.e. you can use this to remove the stars/underscores surrounding bold and italic words.
// The substitution pattern must have either one or two matches. In case it has two, it uses the first
// match to replace its content with the content of the seconds match. If there is only one match, the
// whole match will be replaced by the matched content.
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options andAddAttributes:(NSDictionary *)attributes {
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
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(headRef) forKey:(NSString *)kCTFontAttributeName];
            NSString *text = [string substringWithRange:textRange];
            NSArray *endMatches = [endRegex matchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
            if (endMatches.count == 1) {
                text = [text substringWithRange:NSMakeRange(0, text.length - [(NSTextCheckingResult *)endMatches[0] rangeAtIndex:0].length)];
            }
            [string replaceCharactersInRange:match.range withString:text];
            textRange = NSMakeRange(match.range.location, text.length);
            [self addAttributes:attributes range:textRange];
        }
        CFRelease(baseRef);
    }
}

@end