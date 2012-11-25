#import <UIKit/UIKit.h>
#import "EventCell.h"
#import "PullToRefreshTableViewController.h"


@class GHEvents;

@interface EventsController : PullToRefreshTableViewController <EventCellDelegate>

@property(nonatomic,retain)IBOutlet UITableViewCell *noEntriesCell;
@property(nonatomic,retain)IBOutlet EventCell *selectedCell;
@property(nonatomic,retain)IBOutlet EventCell *eventCell;
@property(nonatomic,retain)NSIndexPath *selectedIndexPath;

+ (id)controllerWithEvents:(GHEvents *)theEvents;
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;

@end