#import <UIKit/UIKit.h>


@class GHIssue, LabeledCell, TextCell, CommentCell, IssuesController;

@interface IssueController : UITableViewController <UIActionSheetDelegate> {
  @private
	GHIssue *issue;
	IssuesController *listController;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIView *tableFooterView;
	IBOutlet UILabel *createdLabel;
	IBOutlet UILabel *updatedLabel;
	IBOutlet UILabel *voteLabel;
	IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *issueNumber;
	IBOutlet UIImageView *iconView;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *loadingCommentsCell;
	IBOutlet UITableViewCell *noCommentsCell;
	IBOutlet LabeledCell *createdCell;
	IBOutlet LabeledCell *updatedCell;
	IBOutlet TextCell *descriptionCell;
	IBOutlet CommentCell *commentCell;
}

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end