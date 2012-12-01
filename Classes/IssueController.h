#import <UIKit/UIKit.h>


@class GHIssue, LabeledCell, TextCell, CommentCell, IssuesController;

@interface IssueController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IssuesController *listController;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UILabel *createdLabel;
@property(nonatomic,strong)IBOutlet UILabel *updatedLabel;
@property(nonatomic,strong)IBOutlet UILabel *voteLabel;
@property(nonatomic,strong)IBOutlet UILabel *titleLabel;
@property(nonatomic,strong)IBOutlet UILabel *issueNumber;
@property(nonatomic,strong)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;

+ (id)controllerWithIssue:(GHIssue *)theIssue;
+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (id)initWithIssue:(GHIssue *)theIssue;
- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end