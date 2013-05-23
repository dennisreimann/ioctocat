//
//  NSAttributedString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (GHFMarkdown)
+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdownString;
+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdownString attributes:(NSDictionary *)attributes;
@end
