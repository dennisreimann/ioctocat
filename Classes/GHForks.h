#import "GHCollection.h"


@class GHRepository;

@interface GHForks : GHCollection
- (id)initWithRepository:(GHRepository *)repo;
@end