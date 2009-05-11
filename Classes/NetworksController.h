#import <Foundation/Foundation.h>
#import "NetworkCell.h"
#import "GHRepository.h"

@interface NetworksController : UITableViewController {
    GHRepository *repository;
@private
    IBOutlet UITableViewCell *loadingNetworksCell;
	IBOutlet UITableViewCell *noNetworksCell;
	IBOutlet NetworkCell *networkCell;    

}
@property (nonatomic, readonly) GHNetworks *currentNetworks;
@property (nonatomic, retain) GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;
- (void)setupNetworks;



@end
