@class GHEvents;

@interface EventsController : UITableViewController
- (id)initWithEvents:(GHEvents *)events;
- (void)openEventItem:(id)eventItem;
- (void)updateRefreshDate;
@end