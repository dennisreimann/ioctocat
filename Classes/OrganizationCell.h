#import <UIKit/UIKit.h>


@class GHOrganization;

@interface OrganizationCell : UITableViewCell {
	GHOrganization *organization;
  @private
	IBOutlet UILabel *loginLabel;
	IBOutlet UIImageView *gravatarView;
}

@property(nonatomic,retain)GHOrganization *organization;

@end
