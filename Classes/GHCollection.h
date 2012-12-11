#import "GHResource.h"


@interface GHCollection : GHResource
@property(nonatomic,readonly)BOOL isEmpty;
@property(nonatomic,readonly)NSUInteger count;
@property(nonatomic,strong)NSMutableArray *items;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (BOOL)containsObject:(id)object;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
@end
