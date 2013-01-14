#import "EventsController.h"


@class GHUser;

@interface MyEventsController : EventsController
- (id)initWithUser:(GHUser *)user;
@end