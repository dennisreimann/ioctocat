#import <UIKit/UIKit.h>


@class GHUser;

@interface UserViewController : UITableViewController {
  @private
	GHUser *user;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *companyLabel;
	IBOutlet UIActivityIndicatorView *activityView;
}

- (id)initWithUser:(GHUser *)theUser;

@end
