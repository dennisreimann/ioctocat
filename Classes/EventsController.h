@class GHEvents;

@interface EventsController : UITableViewController
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (void)updateRefreshDate;
@end