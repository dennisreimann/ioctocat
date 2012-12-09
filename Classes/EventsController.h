#import "PullToRefreshTableViewController.h"


@class GHEvents;

@interface EventsController : PullToRefreshTableViewController
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;
@end