//
//  GHFMarkdown+Private.h
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
- (NSArray *)tasksFromGHFMarkdown;
- (NSArray *)quotesFromGHFMarkdown;
- (NSArray *)headlinesFromGHFMarkdown;
- (NSArray *)linksFromGHFMarkdownLinks;
- (NSArray *)linksFromGHFMarkdownUsernames;
- (NSArray *)linksFromGHFMarkdownWithContextRepoId:(NSString *)repoId;
- (NSArray *)linksFromGHFMarkdownShasWithContextRepoId:(NSString *)repoId;
- (NSArray *)linksFromGHFMarkdownIssuesWithContextRepoId:(NSString *)repoId;
@end

@interface NSMutableString (GHFMarkdown_Private)
- (void)substituteGHFMarkdownHeadlines;
- (void)substituteGHFMarkdownQuotes;
- (void)substituteGHFMarkdownLinks;
- (void)substituteGHFMarkdownTasks;
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSDictionary *)extractAndSubstituteGHFMarkdownCodeBlocks;
- (void)insertSubstitutedGHFMarkdownCodeBlocks:(NSDictionary *)codeBlocks;
@end

@interface NSMutableAttributedString (GHFMarkdown_Private)
- (void)substituteGHFMarkdownLinksWithContextRepoId:(NSString *)contextRepoId;
- (void)substituteGHFMarkdownTasks;
- (void)substituteGHFMarkdownQuotes;
- (void)substituteGHFMarkdownHeadlines;
- (void)substitutePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options addAttributes:(NSDictionary *)attributes;
@end
