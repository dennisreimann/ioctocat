#import <UIKit/UIKit.h>
#import "GHOrganizations.h"
#import "OrganizationCell.h"


@interface OrganizationFeedsController : UITableViewController {
    GHOrganizations *organizations;
@private
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noOrganizationsCell;
    IBOutlet OrganizationCell *organizationCell;
}

@property(nonatomic,retain) GHOrganizations *organizations;

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations;

@end
