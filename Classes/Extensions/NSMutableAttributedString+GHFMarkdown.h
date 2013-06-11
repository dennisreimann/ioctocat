//
//  NSMutableAttributedString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (GHFMarkdown)
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options andAddAttributes:(NSDictionary *)attributes;
- (void)substituteGHFMarkdownHeadlinesWithBaseFont:(UIFont *)baseFont;
@end
