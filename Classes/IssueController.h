@class GHIssue, IssuesController;

@interface IssueController : UITableViewController
- (id)initWithIssue:(GHIssue *)theIssue;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
@end