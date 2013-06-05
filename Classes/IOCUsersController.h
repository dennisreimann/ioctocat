#import "IOCCollectionController.h"

@class GHUsers;

@interface IOCUsersController : IOCCollectionController
- (id)initWithUsers:(GHUsers *)users;
@end