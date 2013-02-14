#import "GHCollection.h"


@interface GHCollection ()
@end


@implementation GHCollection

- (id)init {
	self = [super init];
	if (self) {
		self.items = [NSMutableArray array];
	}
	return self;
}

- (NSUInteger)count {
	return self.items.count;
}

- (BOOL)isEmpty {
	return self.count == 0;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
	return self.items[idx];
}

- (BOOL)containsObject:(id)object {
	return [self.items containsObject:object];
}

- (void)addObject:(id)object {
	[self.items addObject:object];
}

- (void)removeObject:(id)object {
	[self.items removeObject:object];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
	[self.items insertObject:object atIndex:idx];
}

- (void)sortUsingComparator:(NSComparator)cmptr {
	[self.items sortUsingComparator:cmptr];
}

- (void)sortUsingSelector:(SEL)cmptr {
	[self.items sortUsingSelector:cmptr];
}

@end
