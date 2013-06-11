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
#import "NSString+GHFMarkdown.h"

@implementation NSAttributedString (GHFMarkdown)

+ (NSAttributedString *)attributedStringFromGHFMarkdown:(NSString *)markdownString {
    return [self attributedStringFromGHFMarkdown:markdownString attributes:nil];
}

+ (NSAttributedString *)attributedStringFromGHFMarkdown:(NSString *)markdownString attributes:(NSDictionary *)attributes {
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
    [string substituteGHFMarkdownImages];
    [string substituteGHFMarkdownLinks];
    [string substituteGHFMarkdownTasks];
    [output substituteGHFMarkdownHeadlinesWithBaseFont:font];
    [output substitutePattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines) andAddAttributes:quoteAttributes];
    [output substitutePattern:GHFMarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldItalicAttributes];
    [output substitutePattern:GHFMarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldAttributes];
    [output substitutePattern:GHFMarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:italicAttributes];
    [output substitutePattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) andAddAttributes:codeAttributes];
    [output substitutePattern:GHFMarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:codeAttributes];
    return output;
}

@end