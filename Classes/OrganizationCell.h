#import <UIKit/UIKit.h>


@class GHOrganization;

@interface OrganizationCell : UITableViewCell
@property(nonatomic,strong)GHOrganization *organization;
@property(nonatomic,weak)IBOutlet UILabel *loginLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@end