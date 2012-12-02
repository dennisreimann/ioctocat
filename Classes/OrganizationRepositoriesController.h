#import <UIKit/UIKit.h>


@class GHUser;

@interface OrganizationRepositoriesController : UITableViewController
	
@property(nonatomic,strong)NSMutableArray *organizationRepositories;
@property(nonatomic,strong)NSMutableArray *observedOrgRepoLists;
@property(nonatomic,strong)GHUser *user;
@property(weak, nonatomic,readonly)GHUser *currentUser;

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *emptyCell;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *refreshButton;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;

@end