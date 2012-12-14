#import <Foundation/Foundation.h>
#import "GHRepository.h"


@interface ForksController : UITableViewController
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingForksCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noForksCell;	

- (id)initWithRepository:(GHRepository *)repo;
@end