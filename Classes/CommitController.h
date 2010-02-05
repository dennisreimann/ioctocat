#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, FilesCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate> {
	GHCommit *commit;
	LabeledCell *authorCell;
	LabeledCell *committerCell;
	FilesCell *addedCell;
	FilesCell *modifiedCell;
	FilesCell *removedCell;
	UITableViewCell *loadingCell;
	UIView *tableHeaderView;
	UILabel *authorLabel;
	UILabel *committerLabel;
	UILabel *dateLabel;
	UILabel *titleLabel;
	UIImageView *gravatarView;
}

@property(nonatomic,retain)GHCommit *commit;
@property(nonatomic,retain)IBOutlet LabeledCell *authorCell;
@property(nonatomic,retain)IBOutlet LabeledCell *committerCell;
@property(nonatomic,retain)IBOutlet FilesCell *addedCell;
@property(nonatomic,retain)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,retain)IBOutlet FilesCell *removedCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,retain)IBOutlet UIView *tableHeaderView;
@property(nonatomic,retain)IBOutlet UILabel *authorLabel;
@property(nonatomic,retain)IBOutlet UILabel *committerLabel;
@property(nonatomic,retain)IBOutlet UILabel *dateLabel;
@property(nonatomic,retain)IBOutlet UILabel *titleLabel;
@property(nonatomic,retain)IBOutlet UIImageView *gravatarView;

- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;

@end