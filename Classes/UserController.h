#import <UIKit/UIKit.h>


@class GHUser, LabeledCell;

@interface UserController : UITableViewController <UIActionSheetDelegate> {
  @private
	GHUser *user;
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
    IBOutlet UITableViewCell *followingCell;    
	IBOutlet LabeledCell *locationCell;
	IBOutlet LabeledCell *blogCell;
	IBOutlet LabeledCell *emailCell;
    IBOutlet UIView *activityView;
    UIActionSheet *activitySheet;

}

@property (nonatomic, readonly) GHUser *currentUser;

- (id)initWithUser:(GHUser *)theUser;
- (IBAction)showActions:(id)sender;
- (void)toggleFollowing ;


@end
