#import <UIKit/UIKit.h>


@class GHRepository, GHUser, FeedEntryCell, TextCell, LabeledCell, IssueCell;

@interface RepositoryController : UITableViewController {
  @private
	GHRepository *repository;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *numbersLabel;
	IBOutlet UILabel *ownerLabel;
	IBOutlet UILabel *websiteLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *commitsCell;
    IBOutlet UITableViewCell *issuesCell;
    IBOutlet UIImageView *iconView;
	IBOutlet LabeledCell *ownerCell;
	IBOutlet LabeledCell *websiteCell;
	IBOutlet TextCell *descriptionCell;
}

@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithRepository:(GHRepository *)theRepository;
- (IBAction)toggleWatching:(id)sender;

@end
