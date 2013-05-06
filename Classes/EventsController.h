@class GHEvents;

@interface EventsController : UITableViewController
- (id)initWithEvents:(GHEvents *)events;
- (void)refreshLastUpdate;
- (void)refreshIfRequired;
@end