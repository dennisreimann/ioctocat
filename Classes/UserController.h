#import <UIKit/UIKit.h>


@class GHUser, LabeledCell;

@interface UserController : UITableViewController <UIActionSheetDelegate> {
	GHUser *user;
  @private
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *companyLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *blogLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UITableViewCell *loadingUserCell;
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
    IBOutlet UITableViewCell *followersCell; 
    IBOutlet UITableViewCell *followingCell;   
	IBOutlet UITableViewCell *recentActivityCell;
	IBOutlet LabeledCell *locationCell;
	IBOutlet LabeledCell *blogCell;
	IBOutlet LabeledCell *emailCell;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithUser:(GHUser *)theUser;
- (IBAction)showActions:(id)sender;

@end
