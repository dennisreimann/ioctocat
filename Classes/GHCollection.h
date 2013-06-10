#import "GHResource.h"


@interface GHCollection : GHResource
@property(nonatomic,readonly)BOOL isEmpty;
@property(nonatomic,readonly)BOOL hasNextPage;
@property(nonatomic,readonly)NSUInteger count;
@property(nonatomic,strong)NSMutableArray *items;
@property(nonatomic,strong)NSURL *nextPageURL;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (BOOL)containsObject:(id)object;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)object;
- (void)loadNextWithStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)saveObject:(GHResource *)object params:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)deleteObject:(GHResource *)object start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end
