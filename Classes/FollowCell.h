#import <UIKit/UIKit.h>


@class GHUser;

@interface FollowCell : UITableViewCell {
	GHUser *user;
@private
	IBOutlet UILabel *userLabel;
}

@property (nonatomic, retain) GHUser *user;

@end
