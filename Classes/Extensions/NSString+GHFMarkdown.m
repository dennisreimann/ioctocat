//
//  NSString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSString+GHFMarkdown.h"

@implementation NSString (GHFMarkdown)

- (NSAttributedString *)attributedStringFromMarkdown {
    return [self attributedStringFromMarkdownWithAttributes:nil];
}

- (NSAttributedString *)attributedStringFromMarkdownWithAttributes:(NSDictionary *)attrs {
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] initWithString:self attributes:attrs];
    NSMutableString *string = output.mutableString;
    NSArray *matches = nil;
    UIFont *font = [attrs valueForKey:(NSString *)kCTFontAttributeName];
    if (!font) font = [UIFont systemFontOfSize:15.0f];
    CGFloat fontSize = font.pointSize;
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, fontSize, NULL);
    CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    // links
    NSEnumerator *links = [[string markdownLinks] reverseObjectEnumerator];
    for (NSDictionary *link in links) {
        NSRange range = [link[@"range"] rangeValue];
        NSString *title = link[@"title"];
        [string replaceCharactersInRange:range withString:title];
	}
    // bold
    NSRegularExpression *boldRegex = [[NSRegularExpression alloc] initWithPattern:@"[*|_]{2}(.+?)[*|_]{2}" options:NSRegularExpressionCaseInsensitive error:NULL];
    matches = [boldRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange textRange = [match rangeAtIndex:1];
        NSString *text = [string substringWithRange:textRange];
        [string replaceCharactersInRange:match.range withString:text];
        textRange = NSMakeRange(match.range.location, text.length);
        NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(boldFontRef) forKey:(NSString *)kCTFontAttributeName];
        [output addAttributes:boldAttributes range:textRange];
	}
    // italic
    NSRegularExpression *italicRegex = [[NSRegularExpression alloc] initWithPattern:@"[*|_]{1}(.+?)[*|_]{1}" options:NSRegularExpressionCaseInsensitive error:NULL];
    matches = [italicRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange textRange = [match rangeAtIndex:1];
        NSString *text = [string substringWithRange:textRange];
        [string replaceCharactersInRange:match.range withString:text];
        textRange = NSMakeRange(match.range.location, text.length);
        NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(italicFontRef) forKey:(NSString *)kCTFontAttributeName];
        [output addAttributes:italicAttributes range:textRange];
	}
    // tasks
    NSRegularExpression *taskRegex = [[NSRegularExpression alloc] initWithPattern:@"(-\\s?\\[([\\sx])\\]){1}\\s(.+)" options:NSRegularExpressionCaseInsensitive error:NULL];
    matches = [taskRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSEnumerator *tasks = [matches reverseObjectEnumerator];
    for (NSTextCheckingResult *match in tasks) {
        NSRange textRange = [match rangeAtIndex:1];
        NSRange checkRange = [match rangeAtIndex:2];
        NSString *check = [string substringWithRange:checkRange];
        BOOL checked = [check isEqualToString:@"x"];
        NSString *mark = checked ? @"\U00002611" : @"\U000025FB";
        [string replaceCharactersInRange:textRange withString:mark];
	}
    // code block
    NSRegularExpression *codeBlockRegex = [[NSRegularExpression alloc] initWithPattern:@"`{3}(.+)`{3}" options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) error:NULL];
    matches = [codeBlockRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange textRange = [match rangeAtIndex:1];
        NSString *text = [string substringWithRange:textRange];
        [string replaceCharactersInRange:match.range withString:text];
        textRange = [string rangeOfString:text];
        [output addAttributes:codeAttributes range:textRange];
	}
    // inline code
    NSRegularExpression *codeInlineRegex = [[NSRegularExpression alloc] initWithPattern:@"`{1}(.+)`{1}" options:NSRegularExpressionCaseInsensitive error:NULL];
    matches = [codeInlineRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange textRange = [match rangeAtIndex:1];
        NSString *text = [string substringWithRange:textRange];
        [string replaceCharactersInRange:match.range withString:text];
        textRange = NSMakeRange(match.range.location, text.length);
        [output addAttributes:codeAttributes range:textRange];
	}
    return output;
}

// also takes care of images
- (NSArray *)markdownLinks {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"!?\\[(.*?)\\]\\((\\S+)(\\s+(\"|\')(.*?)(\"|\'))?\\)" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange titleRange = [match rangeAtIndex:1];
        NSRange urlRange = [match rangeAtIndex:2];
        NSString *title = [string substringWithRange:titleRange];
        NSString *url = [string substringWithRange:urlRange];
        [results addObject:@{
         @"title": title,
         @"range": [NSValue valueWithRange:match.range],
         @"url": [NSURL URLWithString:url]}];
	}
    return results;
}

@end