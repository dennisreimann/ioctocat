#import <Foundation/Foundation.h>


@interface NSString (Extensions)
- (BOOL)isEmpty;
- (NSString *)escapeHTML;
- (NSString *)stringByEscapingForURLArgument;
@end