#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, FilesCell, CommentCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,weak)IBOutlet LabeledCell *authorCell;
@property(nonatomic,weak)IBOutlet LabeledCell *committerCell;
@property(nonatomic,weak)IBOutlet FilesCell *addedCell;
@property(nonatomic,weak)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,weak)IBOutlet FilesCell *removedCell;
@property(nonatomic,weak)IBOutlet CommentCell *commentCell;
@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UIView *tableFooterView;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,weak)IBOutlet UILabel *authorLabel;
@property(nonatomic,weak)IBOutlet UILabel *committerLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;

+ (id)controllerWithCommit:(GHCommit *)theCommit;
- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end