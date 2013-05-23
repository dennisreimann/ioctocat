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

static NSString *const MarkdownBoldItalicRegex = @"[*_]{3}(.+?)[*_]{3}";
static NSString *const MarkdownBoldRegex = @"[*_]{2}(.+?)[*_]{2}";
static NSString *const MarkdownItalicRegex = @"[*_]{1}(.+?)[*_]{1}";
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
    NSDictionary *boldItalicAttributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(boldFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(italicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [string substituteMarkdownLinks];
    [string substituteMarkdownTasks];
    [output substitutePattern:MarkdownBoldItalicRegex andAddAttributes:boldItalicAttributes];
    [output substitutePattern:MarkdownBoldRegex andAddAttributes:boldAttributes];
    [output substitutePattern:MarkdownItalicRegex andAddAttributes:italicAttributes];
    [output substitutePattern:MarkdownCodeBlockRegex andAddAttributes:codeAttributes];
    [output substitutePattern:MarkdownCodeInlineRegex andAddAttributes:codeAttributes];
    return output;
}

@end