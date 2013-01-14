@class GHIssue, IssuesController;

@interface IssueController : UITableViewController
- (id)initWithIssue:(GHIssue *)issue;
- (id)initWithIssue:(GHIssue *)issue andListController:(IssuesController *)controller;
@end