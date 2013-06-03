//
//  NSAttributedString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSAttributedString+GHFMarkdown.h"
#import "NSMutableAttributedString+GHFMarkdown.h"
#import "NSMutableString+GHFMarkdown.h"

@implementation NSAttributedString (GHFMarkdown)

static NSString *const MarkdownBoldItalicRegex = @"(?:^|\\s)([*_]{3}(.+?)[*_]{3})(?:$|\\s)";
static NSString *const MarkdownBoldRegex = @"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)";
static NSString *const MarkdownItalicRegex = @"(?:^|\\s)([*_]{1}(.+?)[*_]{1})(?:$|\\s)";
static NSString *const MarkdownQuotedRegex = @"^>\\s+(.+)";
static NSString *const MarkdownCodeBlockRegex = @"(?:`{3}|<pre>)(.+?)(?:`{3}|</pre>)";
static NSString *const MarkdownCodeInlineRegex = @"(?:`{1}|<code>)(.+?)(?:`{1}|</code>)";

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdownString {
    return [self attributedStringFromMarkdown:markdownString attributes:nil];
}

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdownString attributes:(NSDictionary *)attributes {
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] initWithString:markdownString attributes:attributes];
    NSMutableString *string = output.mutableString;
    UIFont *font = [attributes valueForKey:(NSString *)kCTFontAttributeName];
    if (!font) font = [UIFont systemFontOfSize:15.0f];
    CGFloat fontSize = font.pointSize;
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, fontSize, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, (kCTFontBoldTrait | kCTFontItalicTrait), (kCTFontBoldTrait | kCTFontItalicTrait));
    CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *boldItalicAttributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(boldFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(italicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    NSDictionary *quoteAttributes = [NSDictionary dictionaryWithObjects:@[(id)[[UIColor grayColor] CGColor]] forKeys:@[(NSString *)kCTForegroundColorAttributeName]];
    CFRelease(fontRef);
    [string substituteMarkdownLinks];
    [string substituteMarkdownTasks];
    [output substituteHeadlinesWithBaseFont:font];
    [output substitutePattern:MarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines) andAddAttributes:quoteAttributes];
    [output substitutePattern:MarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldItalicAttributes];
    [output substitutePattern:MarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldAttributes];
    [output substitutePattern:MarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:italicAttributes];
    [output substitutePattern:MarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) andAddAttributes:codeAttributes];
    [output substitutePattern:MarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:codeAttributes];
    return output;
}

@end