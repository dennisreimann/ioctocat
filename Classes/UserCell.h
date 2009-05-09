#import <UIKit/UIKit.h>


@class GHUser;

@interface UserCell : UITableViewCell {
	GHUser *user;
  @private
	IBOutlet UILabel *userLabel;
	IBOutlet UIImageView *gravatarView;
}

@property (nonatomic, retain) GHUser *user;

@end
