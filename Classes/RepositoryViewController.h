#import <UIKit/UIKit.h>


@class GHRepository, GHUser, FeedEntryCell, TextCell, LabeledCell, OpenIssueCell;

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

	
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *loadingRecentCommitsCell;
    IBOutlet UITableViewCell *loadingOpenIssuesCell;
	IBOutlet UITableViewCell *noRecentCommitsCell;
    IBOutlet UITableViewCell *noOpenIssuesCell;    
	
	IBOutlet FeedEntryCell *feedEntryCell;
    IBOutlet OpenIssueCell *issuesCell;    
	IBOutlet LabeledCell *ownerCell;
	IBOutlet LabeledCell *websiteCell;
	IBOutlet TextCell *descriptionCell;
}

@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithRepository:(GHRepository *)theRepository;
- (IBAction)toggleWatching:(id)sender;

@end
