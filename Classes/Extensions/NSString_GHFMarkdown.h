//
//  NSString_GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSString (GHFMarkdown)
- (NSMutableAttributedString *)ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId;
- (NSMutableAttributedString *)ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes;
@end
