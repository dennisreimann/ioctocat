@class GHRepository, GHUser;

@interface IssuesController : UITableViewController
- (id)initWithRepository:(GHRepository *)repo;
- (id)initWithUser:(GHUser *)user;
- (void)reloadIssues;
@end