#import <UIKit/UIKit.h>
#import "GHIssues.h"
#import "OpenIssueCell.h"


@interface IssuesController : UITableViewController {
  @private
	GHIssues *issues;
	IBOutlet UITableViewCell *loadingIssuesCell;
	IBOutlet UITableViewCell *noIssuesCell;
	IBOutlet OpenIssueCell *issueCell;
}

- (id)initWithIssues:(GHIssues *)theIssues;

@end
