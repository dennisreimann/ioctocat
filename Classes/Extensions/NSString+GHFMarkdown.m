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

static NSString *const MarkdownLinkAndImageRegex = @"!?\\[(.*?)\\]\\((\\S+)(\\s+(\"|\')(.*?)(\"|\'))?\\)";
static NSString *const MarkdownShaRegex = @"(?:([\\w-]+)\\/)?(?:([\\w-]+)@)?(\\w{40})";
static NSString *const MarkdownUsernameRegex = @"(?:^|\\s)+@{1}([\\w-]+)";
static NSString *const MarkdownIssueRegex = @"([\\w-]+/[\\w-]+)?#{1}(\\d+)";
static NSString *const MarkdownTaskRegex = @"(-\\s?\\[([\\sx])\\]){1}\\s(.+)";

// also takes care of images
- (NSArray *)linksFromGHFMarkdownLinks {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownLinkAndImageRegex options:NSRegularExpressionCaseInsensitive error:NULL];
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

- (NSArray *)linksFromGHFMarkdownUsernames {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownUsernameRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange loginRange = [match rangeAtIndex:1];
        NSString *login = [string substringWithRange:loginRange];
        [results addObject:@{
         @"title": [NSString stringWithFormat:@"@%@", login],
         @"login": login,
         @"range": [NSValue valueWithRange:match.range],
         @"url": [NSURL URLWithString:[NSString stringWithFormat:@"/%@", login]]}];
	}
    return results;
}

// Possible matches
//
// * SHA
// * User@SHA
// * User/Project@SHA
- (NSArray *)linksFromGHFMarkdownShasWithContextRepoId:(NSString *)repoId {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownShaRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange titleRange = match.range;
        NSRange firstRange = [match rangeAtIndex:1];
        NSRange secondRange = [match rangeAtIndex:2];
        NSRange shaRange = [match rangeAtIndex:3];
        NSString *sha = [string substringWithRange:shaRange];
        NSString *title = [string substringWithRange:titleRange];
        NSString *repoUser = firstRange.location == NSNotFound ? nil : [string substringWithRange:firstRange];
        NSString *repoName = secondRange.location == NSNotFound ? nil : [string substringWithRange:secondRange];
        // in case only the second group matched, this is the username
        if (!repoUser && repoName) {
            repoUser = repoName;
            repoName = nil;
        }
        // construct the full repo reference, defaults to context repo
        NSString *repo = repoId;
        if (repoUser && repoName) {
            repo = [NSString stringWithFormat:@"%@/%@", repoUser, repoName];
        } else if (repoUser && repoId) {
            // same repo, but different user
            repoName = [repoId lastPathComponent];
            repo = [NSString stringWithFormat:@"%@/%@", repoUser, repoName];
        }
        [results addObject: repo ? @{
         @"title": title,
         @"sha": sha,
         @"repo": repo,
         @"range": [NSValue valueWithRange:match.range],
         @"url": [NSURL URLWithString:[NSString stringWithFormat:@"/%@/commit/%@", repo, sha]]} :
         @{
         @"title": title,
         @"sha": sha,
         @"range": [NSValue valueWithRange:match.range] }];
	}
    return results;
}

- (NSArray *)linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownIssueRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange titleRange = match.range;
        NSRange repoRange = [match rangeAtIndex:1];
        NSRange numRange = [match rangeAtIndex:2];
        NSString *title = [string substringWithRange:titleRange];
        NSString *repo = repoRange.location == NSNotFound ? repoId : [string substringWithRange:repoRange];
        NSString *num = [string substringWithRange:numRange];
        [results addObject: repo ? @{
         @"title": title,
         @"repo": repo,
         @"number": num,
         @"range": [NSValue valueWithRange:match.range],
         @"url": [NSURL URLWithString:[NSString stringWithFormat:@"/%@/issues/%@", repo, num]]} :
         @{
         @"title": title,
         @"number": num,
         @"range": [NSValue valueWithRange:match.range] }];
	}
    return results;
}

- (NSArray *)linksFromGHFMarkdownWithContextRepoId:(NSString *)repoId {
    NSString *string = self;
    NSArray *links = [string linksFromGHFMarkdownLinks];
    NSArray *users = [string linksFromGHFMarkdownUsernames];
    NSArray *shas = [string linksFromGHFMarkdownShasWithContextRepoId:repoId];
    NSArray *issues = [string linksFromGHFMarkdownIssuesWithContextRepoId:repoId];
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:links.count + users.count + issues.count];
    [all addObjectsFromArray:links];
    [all addObjectsFromArray:users];
    [all addObjectsFromArray:shas];
    [all addObjectsFromArray:issues];
    return all;
}

- (NSArray *)tasksFromGHFMarkdown {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:MarkdownTaskRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange markRange = [match rangeAtIndex:1];
        NSRange checkRange = [match rangeAtIndex:2];
        NSRange titleRange = [match rangeAtIndex:3];
        NSString *check = [string substringWithRange:checkRange];
        NSString *title = [string substringWithRange:titleRange];
        BOOL checked = [check isEqualToString:@"x"];
        NSString *mark = checked ? @"\U00002611" : @"\U000025FB";
        [results addObject:@{
         @"title": title,
         @"mark": mark,
         @"titleRange": [NSValue valueWithRange:titleRange],
         @"markRange": [NSValue valueWithRange:markRange],
         @"range": [NSValue valueWithRange:match.range]}];
	}
    return results;
}

@end