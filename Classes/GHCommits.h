#import "GHCollection.h"


@class GHRepository, GHPullRequest;

@interface GHCommits : GHCollection
- (id)initWithRepository:(GHRepository *)repo;
- (id)initWithRepository:(GHRepository *)repo sha:(NSString *)sha;
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
@end