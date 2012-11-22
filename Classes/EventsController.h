#import <UIKit/UIKit.h>
#import "EventCell.h"
#import "PullToRefreshTableViewController.h"


@class GHEvents;

@interface EventsController : PullToRefreshTableViewController <EventCellDelegate> {
	GHEvents *events;
	IBOutlet EventCell *eventCell;
	IBOutlet UITableViewCell *noEntriesCell;
}

@property(nonatomic,retain)EventCell *selectedCell;
@property(nonatomic,retain)NSIndexPath *selectedIndexPath;

+ (id)controllerWithEvents:(GHEvents *)theEvents;
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;

@end