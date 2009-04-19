#import <UIKit/UIKit.h>


@class GHRepository, TextCell, LabeledCell;

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
	IBOutlet LabeledCell *ownerCell;
	IBOutlet LabeledCell *websiteCell;
	IBOutlet TextCell *descriptionCell;
}

- (id)initWithRepository:(GHRepository *)theRepository;

@end
