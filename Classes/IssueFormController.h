#import <UIKit/UIKit.h>


@class GHIssue, IssuesController;

@interface IssueFormController : UITableViewController <UITextFieldDelegate>

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IssuesController *listController;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITextField *titleField;
@property(nonatomic,strong)IBOutlet UITextView *bodyField;
@property(nonatomic,strong)IBOutlet UITableViewCell *titleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *bodyCell;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic,strong)IBOutlet UIButton *saveButton;

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)saveIssue:(id)sender;

@end