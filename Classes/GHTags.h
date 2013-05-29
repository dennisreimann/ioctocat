#import "GHCollection.h"


@class GHRepository;

@interface GHTags : GHCollection
- (id)initWithRepository:(GHRepository *)repo;
@end