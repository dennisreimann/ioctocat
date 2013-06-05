#import "GHRepositories.h"


@class GHRepository;

@interface GHForks : GHRepositories
- (id)initWithRepository:(GHRepository *)repo;
@end