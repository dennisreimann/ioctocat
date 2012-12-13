@class GHPullRequest, PullRequestsController;

@interface PullRequestController : UITableViewController
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
- (id)initWithPullRequest:(GHPullRequest *)pullRequest andListController:(PullRequestsController *)controller;
@end