@class GHIssue, IssuesController;

@interface IssueFormController : UITableViewController
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
@end