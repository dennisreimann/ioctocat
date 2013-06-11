//
//  NSMutableString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSMutableString (GHFMarkdown)
- (void)substituteGHFMarkdown;
- (void)substituteGHFMarkdownImages;
- (void)substituteGHFMarkdownLinks;
- (void)substituteGHFMarkdownTasks;
- (void)substituteGHFMarkdownHeadlines;
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
@end
