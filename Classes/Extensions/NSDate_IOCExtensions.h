#import <Foundation/Foundation.h>


@interface NSDate (IOCExtensions)
- (NSString*)ioc_prettyDate;
- (NSString*)ioc_prettyDateWithReference:(NSDate*)reference;
@end