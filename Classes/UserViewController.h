#import <UIKit/UIKit.h>


@class GHUser, LabeledCell;

@interface UserViewController : UITableViewController {
  @private
	GHUser *user;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *companyLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *blogLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet LabeledCell *locationCell;
	IBOutlet LabeledCell *blogCell;
	IBOutlet LabeledCell *emailCell;
	IBOutlet UIActivityIndicatorView *activityView;
}

- (id)initWithUser:(GHUser *)theUser;

@end
