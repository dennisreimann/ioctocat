#import <Foundation/Foundation.h>


@class GHTree;

@interface TreeController : UITableViewController {
    IBOutlet UITableViewCell *loadingTreeCell;
	IBOutlet UITableViewCell *noEntriesCell;
  @private
    GHTree *tree;
}

+ (id)controllerWithTree:(GHTree *)theTree;
- (id)initWithTree:(GHTree *)theTree;

@end
