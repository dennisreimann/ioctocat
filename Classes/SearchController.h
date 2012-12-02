#import <UIKit/UIKit.h>


@class GHUser, UserCell;

@interface SearchController : UITableViewController

@property(nonatomic,strong)UserCell *userCell;
@property(nonatomic,weak)IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak)IBOutlet UISegmentedControl *searchControl;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noResultsCell;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (void)quitSearching:(id)sender;
- (IBAction)switchChanged:(id)sender;

@end