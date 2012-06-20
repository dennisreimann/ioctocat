#import <UIKit/UIKit.h>

@class UserCell;

@interface AccountsController : UITableViewController {
	NSMutableArray *accounts;
  @private
    IBOutlet UserCell *userCell;
}

@property(nonatomic,retain)NSMutableArray *accounts;

- (IBAction)addAccount:(id)sender;

@end