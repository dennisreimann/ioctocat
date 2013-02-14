@class GHIssue, IOCIssuesController;

@interface IOCIssueController : UITableViewController
- (id)initWithIssue:(GHIssue *)issue;
- (id)initWithIssue:(GHIssue *)issue andListController:(IOCIssuesController *)controller;
@end