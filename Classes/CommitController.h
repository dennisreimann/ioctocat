#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, FilesCell, CommentCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate>
@property(nonatomic,weak)IBOutlet UILabel *authorLabel;
@property(nonatomic,weak)IBOutlet UILabel *committerLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *committerCell;
@property(nonatomic,strong)IBOutlet FilesCell *addedCell;
@property(nonatomic,strong)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,strong)IBOutlet FilesCell *removedCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;

- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;
@end