@class GHEvents;

@interface IOCEventsController : UITableViewController
- (id)initWithEvents:(GHEvents *)events;
- (void)refreshLastUpdate;
- (void)refreshIfRequired;
- (void)displayEvents;
@end