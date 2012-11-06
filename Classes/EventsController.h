#import <UIKit/UIKit.h>
#import "GHEvents.h"
#import "EventCell.h"
#import "PullToRefreshTableViewController.h"


@interface EventsController : PullToRefreshTableViewController <EventCellDelegate> {
	GHEvents *events;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet EventCell *eventCell;
}
@property(nonatomic,retain)NSIndexPath *detailedIndexPath;

+ (id)controllerWithEvents:(GHEvents *)theEvents;
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;

@end
