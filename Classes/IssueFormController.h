#import <UIKit/UIKit.h>


@class GHIssue, IssuesController;

@interface IssueFormController : UITableViewController <UITextFieldDelegate>

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IssuesController *listController;
@property(nonatomic,weak)IBOutlet UIView *tableFooterView;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@property(nonatomic,weak)IBOutlet UITableViewCell *titleCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *bodyCell;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic,weak)IBOutlet UIButton *saveButton;

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)saveIssue:(id)sender;

@end