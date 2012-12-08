#import <UIKit/UIKit.h>


@class GHOrganizations, OrganizationCell;

@interface OrganizationFeedsController : UITableViewController
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noOrganizationsCell;
@property(nonatomic,strong)IBOutlet OrganizationCell *organizationCell;

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations;
@end