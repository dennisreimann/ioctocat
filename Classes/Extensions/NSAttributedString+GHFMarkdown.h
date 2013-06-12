//
//  NSAttributedString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (GHFMarkdown)
+ (NSAttributedString *)attributedStringFromGHFMarkdown:(NSString *)markdownString;
+ (NSAttributedString *)attributedStringFromGHFMarkdown:(NSString *)markdownString attributes:(NSDictionary *)attributes;
@end