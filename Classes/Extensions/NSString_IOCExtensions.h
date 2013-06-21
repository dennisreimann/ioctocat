#import <Foundation/Foundation.h>


@interface NSString (IOCExtensions)
- (BOOL)ioc_isEmpty;
- (NSString *)ioc_escapeHTML;
- (NSString *)ioc_stringByEscapingForURLArgument;
@end