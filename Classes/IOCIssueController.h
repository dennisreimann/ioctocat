@class GHIssue, IssuesController;

@interface IOCIssueController : UITableViewController
- (id)initWithIssue:(GHIssue *)issue;
- (id)initWithIssue:(GHIssue *)issue andListController:(IssuesController *)controller;
@end