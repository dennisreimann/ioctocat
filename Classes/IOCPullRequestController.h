@class GHPullRequest, PullRequestsController;

@interface IOCPullRequestController : UITableViewController
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
- (id)initWithPullRequest:(GHPullRequest *)pullRequest andListController:(PullRequestsController *)controller;
@end