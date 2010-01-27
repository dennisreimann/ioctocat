#import <UIKit/UIKit.h>
#import "GHCommit.h"


@class LabeledCell, TextCell;

@interface CommitController : UITableViewController <UIActionSheetDelegate> {
  @private
	GHCommit *commit;
	LabeledCell *authorCell;
	LabeledCell *committerCell;
	TextCell *messageCell;
	UITableViewCell *loadingCell;
	UIView *tableHeaderView;
	UILabel *authorLabel;
	UILabel *committerLabel;
}

@property(nonatomic,retain)GHCommit *commit;
@property(nonatomic,retain)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,retain)IBOutlet LabeledCell *authorCell;
@property(nonatomic,retain)IBOutlet LabeledCell *committerCell;
@property(nonatomic,retain)IBOutlet TextCell *messageCell;
@property(nonatomic,retain)IBOutlet UIView *tableHeaderView;
@property(nonatomic,retain)IBOutlet UILabel *authorLabel;
@property(nonatomic,retain)IBOutlet UILabel *committerLabel;

- (id)initWithCommit:(GHCommit *)theCommit;
- (IBAction)showActions:(id)sender;

@end