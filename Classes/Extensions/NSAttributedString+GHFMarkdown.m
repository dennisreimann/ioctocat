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
    if (!markdownString) return nil;
    // set up attributes
    UIFont *font = [attributes valueForKey:(NSString *)kCTFontAttributeName];
    if (!font) font = [UIFont systemFontOfSize:15.0f];
    CGFloat fontSize = font.pointSize;
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, fontSize, NULL);
    CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontBoldTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
    CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontItalicTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, (kCTFontBoldTrait | kCTFontItalicTrait), (kCTFontBoldTrait | kCTFontItalicTrait));
    if (!boldItalicFontRef || !italicFontRef) {
        // fix for cases in that font ref variants cannot be resolved - looking at you, HelveticaNeue!
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *italicFont = [UIFont italicSystemFontOfSize:fontSize];
        if (!boldFontRef) boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, fontSize, NULL);
        if (!italicFontRef) italicFontRef = CTFontCreateWithName((__bridge CFStringRef)italicFont.fontName, fontSize, NULL);
        if (!boldItalicFontRef) boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(italicFontRef, fontSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    }
    NSDictionary *boldItalicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:(__bridge id)(boldFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)(italicFontRef) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    NSDictionary *quoteAttributes = [NSDictionary dictionaryWithObjects:@[(id)[[UIColor grayColor] CGColor]] forKeys:@[(NSString *)kCTForegroundColorAttributeName]];
    CFRelease(fontRef);
    CFRelease(boldFontRef);
    CFRelease(italicFontRef);
    CFRelease(boldItalicFontRef);
    // go go go
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] initWithString:markdownString attributes:attributes];
    NSMutableString *string = output.mutableString;
    NSDictionary *codeBlocks = [string extractAndSubstituteGHFMarkdownCodeBlocks];
    [string substituteGHFMarkdownLinks];
    [string substituteGHFMarkdownTasks];
    [output substituteGHFMarkdownHeadlinesWithBaseFont:font];
    [output substitutePattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines) andAddAttributes:quoteAttributes];
    [output substitutePattern:GHFMarkdownBoldItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldItalicAttributes];
    [output substitutePattern:GHFMarkdownBoldRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:boldAttributes];
    [output substitutePattern:GHFMarkdownItalicRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:italicAttributes];
    [output substitutePattern:GHFMarkdownCodeInlineRegex options:(NSRegularExpressionCaseInsensitive) andAddAttributes:codeAttributes];
    [string insertSubstitutedGHFMarkdownCodeBlocks:codeBlocks];
    [output substitutePattern:GHFMarkdownCodeBlockRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) andAddAttributes:codeAttributes];
    return output;
}

@end