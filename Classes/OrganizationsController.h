#import <UIKit/UIKit.h>


@class GHOrganizations, OrganizationCell;

@interface OrganizationsController : UITableViewController {
	@private
	GHOrganizations *organizations;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noOrganizationsCell;
	IBOutlet OrganizationCell *organizationCell;
}

+ (id)controllerWithOrganizations:(GHOrganizations *)theOrganizations;
- (id)initWithOrganizations:(GHOrganizations *)theOrganizations;

@end