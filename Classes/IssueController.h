#import <UIKit/UIKit.h>


@class GHIssue, LabeledCell, TextCell, CommentCell, IssuesController;

@interface IssueController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IssuesController *listController;
@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UIView *tableFooterView;
@property(nonatomic,weak)IBOutlet UILabel *createdLabel;
@property(nonatomic,weak)IBOutlet UILabel *updatedLabel;
@property(nonatomic,weak)IBOutlet UILabel *voteLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *issueNumber;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,weak)IBOutlet LabeledCell *createdCell;
@property(nonatomic,weak)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,weak)IBOutlet TextCell *descriptionCell;
@property(nonatomic,weak)IBOutlet CommentCell *commentCell;

+ (id)controllerWithIssue:(GHIssue *)theIssue;
+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (id)initWithIssue:(GHIssue *)theIssue;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end