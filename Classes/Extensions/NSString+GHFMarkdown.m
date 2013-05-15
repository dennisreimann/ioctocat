//
//  NSString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import "NSString+GHFMarkdown.h"

@implementation NSString (GHFMarkdown)

- (NSAttributedString *)attributedStringFromMarkdown {
    return [self attributedStringFromMarkdownWithAttributes:nil];
}

- (NSAttributedString *)attributedStringFromMarkdownWithAttributes:(NSDictionary *)attrs {
    NSMutableAttributedString *output = [[NSMutableAttributedString alloc] initWithString:self attributes:attrs];
    NSMutableString *string = output.mutableString;
    // links
    NSEnumerator *links = [[string markdownLinks] reverseObjectEnumerator];
    for (NSDictionary *link in links) {
        NSRange range = [link[@"range"] rangeValue];
        NSString *title = link[@"title"];
        [string replaceCharactersInRange:range withString:title];
	}
    return output;
}

- (NSArray *)markdownLinks {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[(.*?)\\]\\((\\S+)(\\s+(\"|\')(.*?)(\"|\'))?\\)" options:NSRegularExpressionCaseInsensitive error:NULL];
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