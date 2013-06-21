#import <Foundation/Foundation.h>


@interface NSMutableArray (IOCExtensions)
- (void)ioc_moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
@end