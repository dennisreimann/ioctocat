#import <UIKit/UIKit.h>


@class GHIssue, IssuesController;

@interface IssueFormController : UITableViewController <UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic,weak)IBOutlet UIButton *saveButton;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *titleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *bodyCell;

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)saveIssue:(id)sender;
@end