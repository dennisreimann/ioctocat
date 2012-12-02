#import <Foundation/Foundation.h>
#import "GHRepository.h"


@interface ForksController : UITableViewController

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingForksCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noForksCell;	

+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end