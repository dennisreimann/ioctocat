//
//  NSString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSString+GHFMarkdown.h"
#import "NSMutableString+GHFMarkdown.h"

@implementation NSString (GHFMarkdown)

NSString *const GHFMarkdownLinkRegex = @"!?\\[([^\\[\\]]+?)\\]\\(([^\\s\\]]+)(\\s+(\"|\')(.+?)(\"|\'))?\\)";
NSString *const GHFMarkdownShaRegex = @"(?:([\\w-]+)\\/)?(?:([\\w-]+)@)?(\\w{40})";
NSString *const GHFMarkdownUsernameRegex = @"(?:^|\\s)@{1}([\\w-]+)";
NSString *const GHFMarkdownIssueRegex = @"(?:([\\w-]+)\\/)?([\\w-]+)?#{1}(\\d+)";
NSString *const GHFMarkdownTaskRegex = @"(-\\s?\\[([\\sx])\\]){1}\\s(.+)";
NSString *const GHFMarkdownHeadlineRegex = @"^(#{1,6})\\s++(.+)$";
NSString *const GHFMarkdownBoldItalicRegex = @"(?:^|\\s)([*_]{3}(.+?)[*_]{3})(?:$|\\s)";
NSString *const GHFMarkdownBoldRegex = @"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)";
NSString *const GHFMarkdownItalicRegex = @"(?:^|\\s)([*_]{1}(.+?)[*_]{1})(?:$|\\s)";
NSString *const GHFMarkdownQuotedRegex = @"(?:^>\\s?)(.+)";
NSString *const GHFMarkdownCodeBlockRegex = @"(?:`{3}(?:\\w+\n)?|<pre>)(.+?)(?:`{3}|</pre>)";
NSString *const GHFMarkdownCodeInlineRegex = @"(?:`{1}|<code>)(.+?)(?:`{1}|</code>)";

- (NSArray *)linksFromGHFMarkdownLinks {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownLinkRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
    NSMutableArray *results = [[NSMutableArray alloc] init];
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
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownUsernameRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
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
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownShaRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
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

// Possible matches
//
// * #Num
// * User/#Num
// * User/Project#Num
- (NSArray *)linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownIssueRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange titleRange = match.range;
        NSRange firstRange = [match rangeAtIndex:1];
        NSRange secondRange = [match rangeAtIndex:2];
        NSRange numRange = [match rangeAtIndex:3];
        NSString *num = [string substringWithRange:numRange];
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
    NSMutableString *string = self.mutableCopy;
    [string extractAndSubstituteGHFMarkdownCodeBlocks];
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
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownTaskRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
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

- (NSArray *)headlinesFromGHFMarkdown {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownHeadlineRegex options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines) error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    NSRegularExpression *endRegex = [[NSRegularExpression alloc] initWithPattern:@"\\s+#{1,6}\\s*$" options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines) error:NULL];
    for (NSTextCheckingResult *match in matches) {
        NSRange headRange = [match rangeAtIndex:1];
        NSUInteger level = headRange.length;
        NSRange titleRange = [match rangeAtIndex:2];
        NSString *title = [string substringWithRange:titleRange];
        NSString *headline = [string substringWithRange:match.range];
        NSArray *endMatches = [endRegex matchesInString:title options:NSMatchingReportCompletion range:NSMakeRange(0, title.length)];
        if (endMatches.count == 1) {
            titleRange = NSMakeRange(0, title.length - [(NSTextCheckingResult *)endMatches[0] rangeAtIndex:0].length);
            title = [title substringWithRange:titleRange];
        }
        [results addObject:@{
         @"title": title,
         @"headline": headline,
         @"level": [NSNumber numberWithInteger:level],
         @"titleRange": [NSValue valueWithRange:titleRange],
         @"range": [NSValue valueWithRange:match.range]}];
    }
    return results;
}

@end