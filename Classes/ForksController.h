#import <Foundation/Foundation.h>
#import "GHRepository.h"


@interface ForksController : UITableViewController {
    IBOutlet UITableViewCell *loadingForksCell;
	IBOutlet UITableViewCell *noForksCell;
  @private
    GHRepository *repository;
}

- (id)initWithRepository:(GHRepository *)theRepository;

@end
