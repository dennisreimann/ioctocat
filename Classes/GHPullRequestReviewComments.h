#import "GHCollection.h"


@class GHPullRequest;

@interface GHPullRequestReviewComments : GHCollection
- (id)initWithParent:(GHPullRequest *)parent;
@end