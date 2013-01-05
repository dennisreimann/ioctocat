#import "GHCollection.h"


@class GHPullRequest;

@interface GHFiles : GHCollection
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
@end