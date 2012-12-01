#import <Foundation/Foundation.h>


@class GHTree;

@interface TreeController : UITableViewController

@property(nonatomic,strong)IBOutlet UITableViewCell *loadingTreeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;

+ (id)controllerWithTree:(GHTree *)theTree;
- (id)initWithTree:(GHTree *)theTree;

@end