#import "GHCollection.h"


@class GHRepository;

@interface GHMilestones : GHCollection
- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo;
@end