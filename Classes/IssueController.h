#import <UIKit/UIKit.h>
#import "GHIssue.h"


@class LabeledCell, TextCell;

@interface IssueController : UITableViewController <UIActionSheetDelegate> {
  @private
	GHIssue *issue;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UILabel *createdLabel;
	IBOutlet UILabel *updatedLabel;
	IBOutlet UILabel *voteLabel;
	IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *issueNumber;
	IBOutlet UIImageView *iconView;
	IBOutlet LabeledCell *createdCell;
	IBOutlet LabeledCell *updatedCell;
	IBOutlet TextCell *descriptionCell;
}

- (id)initWithIssue:(GHIssue *)theIssue;
- (IBAction)showActions:(id)sender;

@end