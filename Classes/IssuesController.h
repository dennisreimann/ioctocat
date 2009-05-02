#import <UIKit/UIKit.h>
#import "GHIssues.h"
#import "IssueCell.h"


@interface IssuesController : UITableViewController {
  @private
	GHIssues *issues;
	IBOutlet UITableViewCell *loadingIssuesCell;
	IBOutlet UITableViewCell *noIssuesCell;
	IBOutlet IssueCell *issueCell;
}

- (id)initWithIssues:(GHIssues *)theIssues;

@end
