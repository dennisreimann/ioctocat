#import "GHCollection.h"


@class GHRepository;

@interface GHPullRequests : GHCollection
- (id)initWithRepository:(GHRepository *)repo andState:(NSString *)state;
@end