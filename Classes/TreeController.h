#import <Foundation/Foundation.h>


@class GHTree;

@interface TreeController : UITableViewController

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingTreeCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noEntriesCell;

+ (id)controllerWithTree:(GHTree *)theTree;
- (id)initWithTree:(GHTree *)theTree;

@end