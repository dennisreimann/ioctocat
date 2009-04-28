#import <UIKit/UIKit.h>


@class GHRepository, GHFeedEntryCell, TextCell, LabeledCell;

@interface RepositoryViewController : UITableViewController {
  @private
	GHRepository *repository;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *numbersLabel;
	IBOutlet UILabel *ownerLabel;
	IBOutlet UILabel *websiteLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *loadingRecentCommitsCell;
	IBOutlet UITableViewCell *noRecentCommitsCell;
	IBOutlet GHFeedEntryCell *feedEntryCell;
	IBOutlet LabeledCell *ownerCell;
	IBOutlet LabeledCell *websiteCell;
	IBOutlet TextCell *descriptionCell;
}

- (id)initWithRepository:(GHRepository *)theRepository;

@end
