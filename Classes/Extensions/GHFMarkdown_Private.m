//
//  GHFMarkdown_Private.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import "GHFMarkdown_Private.h"

NSString *const GHFMarkdownLinkRegex = @"!?\\[([^\\[\\]]+?)\\]\\(([^\\s\\]]+)(\\s+(\"|\')(.+?)(\"|\'))?\\)";
NSString *const GHFMarkdownShaRegex = @"(?:([\\w-]+)\\/)?(?:([\\w-]+)@)?(\\w{40})";
NSString *const GHFMarkdownUsernameRegex = @"(?:^|\\s)(@{1}[\\w-]+)";
NSString *const GHFMarkdownIssueRegex = @"(?:([\\w-]+)\\/)?([\\w-]+)?#{1}(\\d+)";
NSString *const GHFMarkdownTaskRegex = @"(-\\s?\\[([\\sx])\\]){1}\\s(.+)";
NSString *const GHFMarkdownHeadlineRegex = @"^(#{1,6})\\s++(.+)$";
NSString *const GHFMarkdownBoldItalicRegex = @"(?:^|\\s)([*_]{3}(.+?)[*_]{3})(?:$|\\s)";
NSString *const GHFMarkdownBoldRegex = @"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)";
NSString *const GHFMarkdownItalicRegex = @"(?:^|\\s)([*_]{1}(.+?)[*_]{1})(?:$|\\s)";
NSString *const GHFMarkdownQuotedRegex = @"(\n*)(^>.+?)(\n*^)[^>]";
NSString *const GHFMarkdownCodeBlockRegex = @"(?:`{3}(?:\\w+\n)?|<pre>)(.+?)(?:`{3}|</pre>)";
NSString *const GHFMarkdownCodeInlineRegex = @"(?:`{1}|<code>)(.+?)(?:`{1}|</code>)";
NSString *const GHFMarkdownSubstitutionFormat = @"{GHFMarkdownSubstitution-%@}";
NSString *const GHFMarkdownQuoteNewlinePadding = @"\n\n";

NSString *GHFMarkdownMD5(NSString *string) {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}