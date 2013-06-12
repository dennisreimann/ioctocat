//
//  NSString+GHFMarkdown.h
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <Foundation/Foundation.h>

@interface NSString (GHFMarkdown)
- (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId;
- (NSMutableAttributedString *)mutableAttributedStringFromGHFMarkdownWithContextRepoId:(NSString *)contextRepoId attributes:(NSDictionary *)attributes;
@end
