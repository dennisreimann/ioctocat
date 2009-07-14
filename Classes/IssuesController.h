#import <UIKit/UIKit.h>
#import "GHIssues.h"
#import "IssueCell.h"
#import "GHRepository.h"


@interface IssuesController : UITableViewController {
    GHRepository *repository;
  @private
	IBOutlet UISegmentedControl *issuesControl;
	IBOutlet UITableViewCell *loadingIssuesCell;
	IBOutlet UITableViewCell *noIssuesCell;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet IssueCell *issueCell;
    NSArray *issueList;
	NSUInteger loadCounter;
}

@property (nonatomic, readonly) GHIssues *currentIssues;
@property (nonatomic, retain) GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;

@end
