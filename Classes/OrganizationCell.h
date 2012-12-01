#import <UIKit/UIKit.h>


@class GHOrganization;

@interface OrganizationCell : UITableViewCell

@property(nonatomic,strong)GHOrganization *organization;
@property(nonatomic,strong)IBOutlet UILabel *loginLabel;
@property(nonatomic,strong)IBOutlet UIImageView *gravatarView;

@end