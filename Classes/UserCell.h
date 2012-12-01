#import <UIKit/UIKit.h>


@class GHUser;

@interface UserCell : UITableViewCell

@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)IBOutlet UILabel *userLabel;
@property(nonatomic,strong)IBOutlet UIImageView *gravatarView;

@end