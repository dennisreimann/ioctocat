#import <UIKit/UIKit.h>


@class GHUser;

@interface OrganizationRepositoriesController : UITableViewController
	
@property(nonatomic,strong)NSMutableArray *organizationRepositories;
@property(nonatomic,strong)NSMutableArray *observedOrgRepoLists;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)GHUser *currentUser;

@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *emptyCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;

@end