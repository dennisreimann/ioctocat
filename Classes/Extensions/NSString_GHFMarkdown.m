//
//  NSString_GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "GHFMarkdown.h"
#import "GHFMarkdown_Private.h"


@implementation NSString (GHFMarkdown)

- (NSMutableAttributedString *)ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId {
    return [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:self contextRepoId:contextRepoId];
}

- (NSMutableAttributedString *)ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes {
    return [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:self contextRepoId:contextRepoId attributes:attributes];
}

- (NSArray *)ghf_linksFromGHFMarkdownWithContextRepoId:(NSString *)repoId {
    NSMutableString *string = self.mutableCopy;
    NSDictionary *codeBlocks = [string ghf_extractAndSubstituteGHFMarkdownCodeBlocks];
    NSArray *links = [string ghf_linksFromGHFMarkdownLinks];
    NSArray *users = [string ghf_linksFromGHFMarkdownUsernames];
    NSArray *shas = [string ghf_linksFromGHFMarkdownShasWithContextRepoId:repoId];
    NSArray *issues = [string ghf_linksFromGHFMarkdownIssuesWithContextRepoId:repoId];
    [string ghf_insertSubstitutedGHFMarkdownCodeBlocks:codeBlocks];
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:links.count + users.count + shas.count + issues.count];
    [all addObjectsFromArray:links];
    [all addObjectsFromArray:users];
    [all addObjectsFromArray:shas];
    [all addObjectsFromArray:issues];
    return all;
}

- (NSArray *)ghf_headlinesFromGHFMarkdown {
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

- (NSArray *)ghf_quotesFromGHFMarkdown {
    // hack: tappends some extra newlines at the end of the string
    // to also find a quote at the end of the original string
    NSString *string = [self stringByAppendingString:GHFMarkdownQuoteNewlinePadding];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownQuotedRegex options:(NSRegularExpressionAnchorsMatchLines|NSRegularExpressionDotMatchesLineSeparators) error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange newlinesBeforeRange = [match rangeAtIndex:1];
        NSRange titleRange = [match rangeAtIndex:2];
        NSRange newlinesAfterRange = [match rangeAtIndex:3];
        NSString *title = [string substringWithRange:titleRange];
        [results addObject:@{
         @"title": title,
         @"titleRange": [NSValue valueWithRange:titleRange],
         @"newlinesAfterRange": [NSValue valueWithRange:newlinesAfterRange],
         @"newlinesBeforeRange": [NSValue valueWithRange:newlinesBeforeRange],
         @"range": [NSValue valueWithRange:match.range]}];
    }
    return results;
}

- (NSArray *)ghf_linksFromGHFMarkdownLinks {
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

- (NSArray *)ghf_tasksFromGHFMarkdown {
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
        [results addObject:@{
         @"title": title,
         @"checked": [NSNumber numberWithBool:checked],
         @"titleRange": [NSValue valueWithRange:titleRange],
         @"markRange": [NSValue valueWithRange:markRange],
         @"range": [NSValue valueWithRange:match.range]}];
	}
    return results;
}

- (NSArray *)ghf_linksFromGHFMarkdownUsernames {
    NSString *string = self;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:GHFMarkdownUsernameRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (!matches.count) return @[];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange titleRange = [match rangeAtIndex:1];
        NSString *title = [string substringWithRange:titleRange];
        NSString *login = [title substringFromIndex:1];
        [results addObject:@{
         @"title": title,
         @"login": login,
         @"range": [NSValue valueWithRange:titleRange],
         @"url": [NSURL URLWithString:[NSString stringWithFormat:@"/%@", login]]}];
	}
    return results;
}

// Possible matches
//
// * SHA
// * User@SHA
// * User/Project@SHA
- (NSArray *)ghf_linksFromGHFMarkdownShasWithContextRepoId:(NSString *)repoId {
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
- (NSArray *)ghf_linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId {
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

@end