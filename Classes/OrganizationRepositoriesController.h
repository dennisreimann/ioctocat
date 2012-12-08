#import <UIKit/UIKit.h>


@class GHUser;

@interface OrganizationRepositoriesController : UITableViewController
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *emptyCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;

- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;
@end