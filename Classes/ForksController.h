#import <Foundation/Foundation.h>
#import "GHRepository.h"


@interface ForksController : UITableViewController
- (id)initWithRepository:(GHRepository *)repo;
@end