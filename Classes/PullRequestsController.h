@class GHRepository;

@interface PullRequestsController : UITableViewController
- (id)initWithRepository:(GHRepository *)repo;
- (void)reloadPullRequests;
@end