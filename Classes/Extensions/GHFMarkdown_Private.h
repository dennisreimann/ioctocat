//
//  GHFMarkdown_Private.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

extern NSString *const GHFMarkdownLinkRegex;
extern NSString *const GHFMarkdownImageRegex;
extern NSString *const GHFMarkdownShaRegex;
extern NSString *const GHFMarkdownUsernameRegex;
extern NSString *const GHFMarkdownIssueRegex;
extern NSString *const GHFMarkdownTaskRegex;
extern NSString *const GHFMarkdownHeadlineRegex;
extern NSString *const GHFMarkdownBoldItalicRegex;
extern NSString *const GHFMarkdownBoldRegex;
extern NSString *const GHFMarkdownItalicRegex;
extern NSString *const GHFMarkdownQuotedRegex;
extern NSString *const GHFMarkdownCodeBlockRegex;
extern NSString *const GHFMarkdownCodeInlineRegex;
extern NSString *const GHFMarkdownSubstitutionFormat;
extern NSString *const GHFMarkdownQuoteNewlinePadding;

NSString *GHFMarkdownMD5(NSString *string);

@interface NSString (GHFMarkdown_Private)
- (NSArray *)ghf_tasksFromGHFMarkdown;
- (NSArray *)ghf_quotesFromGHFMarkdown;
- (NSArray *)ghf_headlinesFromGHFMarkdown;
- (NSArray *)ghf_linksFromGHFMarkdownLinks;
- (NSArray *)ghf_linksFromGHFMarkdownUsernames;
- (NSArray *)ghf_linksFromGHFMarkdownWithContextRepoId:(NSString *)repoId;
- (NSArray *)ghf_linksFromGHFMarkdownShasWithContextRepoId:(NSString *)repoId;
- (NSArray *)ghf_linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId;
@end

@interface NSMutableString (GHFMarkdown_Private)
- (void)ghf_substituteGHFMarkdownHeadlines;
- (void)ghf_substituteGHFMarkdownQuotes;
- (void)ghf_substituteGHFMarkdownLinks;
- (void)ghf_substituteGHFMarkdownTasks;
- (void)ghf_substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSDictionary *)ghf_extractAndSubstituteGHFMarkdownCodeBlocks;
- (void)ghf_insertSubstitutedGHFMarkdownCodeBlocks:(NSDictionary *)codeBlocks;
@end

@interface NSMutableAttributedString (GHFMarkdown_Private)
- (void)ghf_substituteGHFMarkdownLinksWithContextRepoId:(NSString *)contextRepoId;
- (void)ghf_substituteGHFMarkdownTasks;
- (void)ghf_substituteGHFMarkdownQuotes;
- (void)ghf_substituteGHFMarkdownHeadlines;
- (void)ghf_substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options addAttributes:(NSDictionary *)attributes;
@end
