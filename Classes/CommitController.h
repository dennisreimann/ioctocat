#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, FilesCell, CommentCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate> {
	GHCommit *commit;
	IBOutlet LabeledCell *authorCell;
	IBOutlet LabeledCell *committerCell;
	IBOutlet FilesCell *addedCell;
	IBOutlet FilesCell *modifiedCell;
	IBOutlet FilesCell *removedCell;
	IBOutlet CommentCell *commentCell;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIView *tableFooterView;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *loadingCommentsCell;
	IBOutlet UITableViewCell *noCommentsCell;
	IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *committerLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *gravatarView;
}

+ (id)controllerWithCommit:(GHCommit *)theCommit;
- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end