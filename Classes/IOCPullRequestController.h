@class GHPullRequest, IOCPullRequestsController;

@interface IOCPullRequestController : UITableViewController
- (id)initWithPullRequest:(GHPullRequest *)pullRequest;
- (id)initWithPullRequest:(GHPullRequest *)pullRequest andListController:(IOCPullRequestsController *)controller;
@end