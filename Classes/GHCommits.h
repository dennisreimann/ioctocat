#import "GHCollection.h"


@class GHRepository, GHPullRequest;

@interface GHCommits : GHCollection
- (id)initWithRepository:(GHRepository *)repo;
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
@end