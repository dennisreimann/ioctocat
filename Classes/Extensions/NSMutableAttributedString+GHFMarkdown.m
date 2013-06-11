//
//  NSMutableAttributedString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSMutableAttributedString+GHFMarkdown.h"
#import "NSString+GHFMarkdown.h"

@implementation NSMutableAttributedString (GHFMarkdown)

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

- (void)substituteGHFMarkdownHeadlinesWithBaseFont:(UIFont *)baseFont {
    NSMutableString *string = self.mutableString;
    NSArray *headlines = [string headlinesFromGHFMarkdown];
    if (headlines.count) {
        CGFloat baseSize = baseFont.pointSize;
        CTFontRef baseRef = CTFontCreateWithName((__bridge CFStringRef)baseFont.fontName, baseSize, NULL);
        NSEnumerator *enumerator = [headlines reverseObjectEnumerator];
        for (NSDictionary *headline in enumerator) {
            NSString *title = headline[@"title"];
            NSRange range = [headline[@"range"] rangeValue];
            NSInteger level = [headline[@"level"] integerValue];
            CGFloat headSize =  baseSize + (6 - level);
            CTFontRef headRef = CTFontCreateCopyWithSymbolicTraits(baseRef, headSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(headRef) forKey:(NSString *)kCTFontAttributeName];
            [self addAttributes:attributes range:range];
            [string replaceCharactersInRange:range withString:title];
        }
        CFRelease(baseRef);
    }
}

@end