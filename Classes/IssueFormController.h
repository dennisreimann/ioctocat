#import <UIKit/UIKit.h>
#import "GHIssue.h"


@interface IssueFormController : UITableViewController <UITextFieldDelegate> {
  @private
	GHIssue *issue;
	IBOutlet UIView *tableFooterView;
	IBOutlet UITextField *titleField;
	IBOutlet UITextView *bodyField;
	IBOutlet UIButton *saveButton;
	IBOutlet UITableViewCell *titleCell;
	IBOutlet UITableViewCell *bodyCell;
}

@property (nonatomic, readonly) BOOL isNewIssue;

- (id)initWithIssue:(GHIssue *)theIssue;
- (IBAction)saveIssue:(id)sender;

@end