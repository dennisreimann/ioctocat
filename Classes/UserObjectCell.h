#import <UIKit/UIKit.h>


@interface UserObjectCell : UITableViewCell
@property(nonatomic,strong)id userObject;
@property(nonatomic,weak)IBOutlet UILabel *loginLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@end