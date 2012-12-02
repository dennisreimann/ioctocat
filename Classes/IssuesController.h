#import <UIKit/UIKit.h>


@class GHIssues, IssueCell, GHRepository, GHUser;

@interface IssuesController : UITableViewController
@property(nonatomic,strong)IBOutlet UISegmentedControl *issuesControl;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingIssuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noIssuesCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet IssueCell *issueCell;

+ (id)controllerWithUser:(GHUser *)theUser;
+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithUser:(GHUser *)theUser;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)reloadIssues;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;
- (IBAction)refresh:(id)sender;
@end