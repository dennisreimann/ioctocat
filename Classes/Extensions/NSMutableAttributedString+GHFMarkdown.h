//
//  NSMutableAttributedString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (GHFMarkdown)
+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString;
+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId;
+ (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdown:(NSString *)markdownString contextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes;
- (void)applyAttributes:(NSDictionary *)attributes;
@end