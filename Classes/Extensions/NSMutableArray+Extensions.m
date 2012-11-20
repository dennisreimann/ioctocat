#import "NSMutableArray+Extensions.h"


@implementation NSMutableArray (Extensions)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
	if (to != from) {
		id obj = [self objectAtIndex:from];
		[obj retain];
		[self removeObjectAtIndex:from];
		if (to >= [self count]) {
			[self addObject:obj];
		} else {
			[self insertObject:obj atIndex:to];
		}
		[obj release];
	}
}

@end