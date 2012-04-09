#import <Foundation/Foundation.h>
#import "ForkCell.h"
#import "GHRepository.h"


@interface ForksController : UITableViewController {
    GHRepository *repository;
  @private
    IBOutlet UITableViewCell *loadingForksCell;
	IBOutlet UITableViewCell *noForksCell;
	IBOutlet ForkCell *forkCell;
}

@property(nonatomic,readonly)GHForks *currentForks;
@property(nonatomic,retain)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;

@end
