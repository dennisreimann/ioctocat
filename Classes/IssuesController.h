#import <UIKit/UIKit.h>


@class GHIssues, IssueCell, GHRepository, GHUser;

@interface IssuesController : UITableViewController {
	IBOutlet UISegmentedControl *issuesControl;
	IBOutlet UITableViewCell *loadingIssuesCell;
	IBOutlet UITableViewCell *noIssuesCell;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet IssueCell *issueCell;
  @private
	GHUser *user;
    GHRepository *repository;
    NSArray *issueList;
	NSUInteger loadCounter;
}

+ (id)controllerWithUser:(GHUser *)theUser;
+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithUser:(GHUser *)theUser;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;

@end
