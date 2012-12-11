@class GHRepository, GHUser;

@interface IssuesController : UITableViewController
- (id)initWithUser:(GHUser *)theUser;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
@end