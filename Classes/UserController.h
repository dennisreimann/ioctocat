#import <UIKit/UIKit.h>


@class GHUser, LabeledCell;

@interface UserController : UITableViewController {
  @private
	GHUser *user;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIButton *followButton;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *companyLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *blogLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UITableViewCell *loadingUserCell;
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
    IBOutlet UITableViewCell *followingCell;    
	IBOutlet LabeledCell *locationCell;
	IBOutlet LabeledCell *blogCell;
	IBOutlet LabeledCell *emailCell;
}

@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithUser:(GHUser *)theUser;
- (IBAction)toggleFollowing:(id)sender;

@end
