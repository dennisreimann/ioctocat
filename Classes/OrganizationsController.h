#import <UIKit/UIKit.h>


@class GHOrganizations, UserObjectCell;

@interface OrganizationsController : UITableViewController
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noOrganizationsCell;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations;
@end