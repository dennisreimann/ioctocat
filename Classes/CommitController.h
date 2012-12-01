#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, FilesCell, CommentCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)GHCommit *commit;
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
@property(nonatomic,strong)IBOutlet UILabel *authorLabel;
@property(nonatomic,strong)IBOutlet UILabel *committerLabel;
@property(nonatomic,strong)IBOutlet UILabel *dateLabel;
@property(nonatomic,strong)IBOutlet UILabel *titleLabel;
@property(nonatomic,strong)IBOutlet UIImageView *gravatarView;

+ (id)controllerWithCommit:(GHCommit *)theCommit;
- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end