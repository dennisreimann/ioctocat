//
//  GHFMarkdown+Private.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import "GHFMarkdown+Private.h"

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