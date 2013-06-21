//
//  NSMutableAttributedString_GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (GHFMarkdown)
+ (NSMutableAttributedString *)ghf_mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString;
+ (NSMutableAttributedString *)ghf_mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId;
+ (NSMutableAttributedString *)ghf_mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes;
- (void)ghf_applyAttributes:(NSDictionary *)attributes;
@end