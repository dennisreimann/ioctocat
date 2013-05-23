//
//  NSString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSString (GHFMarkdown)
- (NSArray *)linksFromGHFMarkdownWithContextRepoId:(NSString *)repoId;
- (NSArray *)linksFromGHFMarkdownLinks;
- (NSArray *)linksFromGHFMarkdownUsernames;
- (NSArray *)linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId;
- (NSArray *)tasksFromGHFMarkdown;
@end
