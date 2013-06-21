#import "NSMutableArray_IOCExtensions.h"


@implementation NSMutableArray (IOCExtensions)

- (void)ioc_moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
	if (to != from) {
		id obj = self[from];
		[self removeObjectAtIndex:from];
		if (to >= [self count]) {
			[self addObject:obj];
		} else {
			[self insertObject:obj atIndex:to];
		}
	}
}

@end