#import <UIKit/UIKit.h>


@class GHIssue, IssuesController;

@interface IssueFormController : UITableViewController <UITextFieldDelegate> {
  @private
	GHIssue *issue;
	IssuesController *listController;
	IBOutlet UIView *tableFooterView;
	IBOutlet UITextField *titleField;
	IBOutlet UITextView *bodyField;
	IBOutlet UITableViewCell *titleCell;
	IBOutlet UITableViewCell *bodyCell;
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIButton *saveButton;
}

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)saveIssue:(id)sender;

@end