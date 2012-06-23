#import <UIKit/UIKit.h>


@class GHIssues, IssueCell, GHRepository;

@interface IssuesController : UITableViewController {
	IBOutlet UISegmentedControl *issuesControl;
	IBOutlet UITableViewCell *loadingIssuesCell;
	IBOutlet UITableViewCell *noIssuesCell;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet IssueCell *issueCell;
  @private
    GHRepository *repository;
    NSArray *issueList;
	NSUInteger loadCounter;
}

- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;

@end
