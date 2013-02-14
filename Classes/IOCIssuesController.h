@class GHRepository, GHUser;

@interface IOCIssuesController : UITableViewController
- (id)initWithRepository:(GHRepository *)repo;
- (id)initWithUser:(GHUser *)user;
- (void)reloadIssues;
@end