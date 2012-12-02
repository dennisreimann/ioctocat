#import <UIKit/UIKit.h>


@class GHOrganizations, OrganizationCell;

@interface OrganizationsController : UITableViewController

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noOrganizationsCell;
@property(nonatomic,weak)IBOutlet OrganizationCell *organizationCell;

+ (id)controllerWithOrganizations:(GHOrganizations *)theOrganizations;
- (id)initWithOrganizations:(GHOrganizations *)theOrganizations;

@end