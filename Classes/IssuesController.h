@class GHRepository, GHUser;

@interface IssuesController : UITableViewController
- (id)initWithRepository:(GHRepository *)theRepository;
- (id)initWithUser:(GHUser *)theUser;
- (void)reloadIssues;
@end