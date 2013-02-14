@class GHRepository;

@interface IOCPullRequestsController : UITableViewController
- (id)initWithRepository:(GHRepository *)repo;
- (void)reloadPullRequests;
@end