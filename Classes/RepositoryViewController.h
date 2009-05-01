#import <UIKit/UIKit.h>


@class GHRepository, GHUser, FeedEntryCell, TextCell, LabeledCell;

@interface RepositoryViewController : UITableViewController {
  @private
	GHRepository *repository;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *numbersLabel;
	IBOutlet UIButton *watchButton;
	IBOutlet UILabel *ownerLabel;
	IBOutlet UILabel *websiteLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UILabel *issueLabel;	
	
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *loadingRecentCommitsCell;
	IBOutlet UITableViewCell *noRecentCommitsCell;
	
	IBOutlet FeedEntryCell *feedEntryCell;
	IBOutlet LabeledCell *ownerCell;
	IBOutlet LabeledCell *websiteCell;
	IBOutlet LabeledCell *issueCell;
	IBOutlet TextCell *descriptionCell;
}

@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithRepository:(GHRepository *)theRepository;
- (IBAction)toggleWatching:(id)sender;

@end
