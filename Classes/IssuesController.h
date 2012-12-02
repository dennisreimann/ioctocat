#import <UIKit/UIKit.h>


@class GHIssues, IssueCell, GHRepository, GHUser;

@interface IssuesController : UITableViewController

@property(nonatomic,weak)IBOutlet UISegmentedControl *issuesControl;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingIssuesCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noIssuesCell;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,weak)IBOutlet IssueCell *issueCell;

+ (id)controllerWithUser:(GHUser *)theUser;
+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithUser:(GHUser *)theUser;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;
- (IBAction)refresh:(id)sender;

@end