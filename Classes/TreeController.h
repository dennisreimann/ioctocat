#import <Foundation/Foundation.h>


@class GHTree;

@interface TreeController : UITableViewController
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingTreeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;

- (id)initWithTree:(GHTree *)tree;
@end