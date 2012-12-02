#import <UIKit/UIKit.h>


@class GHUser;

@interface UserCell : UITableViewCell
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,weak)IBOutlet UILabel *userLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@end