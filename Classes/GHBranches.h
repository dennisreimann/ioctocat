#import "GHCollection.h"


@class GHRepository;

@interface GHBranches : GHCollection
- (id)initWithRepository:(GHRepository *)repo;
@end