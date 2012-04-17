#import <Foundation/Foundation.h>
#import "GHRepository.h"


@interface ForksController : UITableViewController {
    GHRepository *repository;
  @private
    IBOutlet UITableViewCell *loadingForksCell;
	IBOutlet UITableViewCell *noForksCell;
}

@property(nonatomic,readonly)GHForks *currentForks;
@property(nonatomic,retain)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;

@end
