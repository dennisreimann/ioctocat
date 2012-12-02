#import <UIKit/UIKit.h>
#import "EventCell.h"
#import "PullToRefreshTableViewController.h"


@class GHEvents;

@interface EventsController : PullToRefreshTableViewController <EventCellDelegate>
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;
@property(nonatomic,strong)IBOutlet EventCell *selectedCell;
@property(nonatomic,strong)IBOutlet EventCell *eventCell;

+ (id)controllerWithEvents:(GHEvents *)theEvents;
- (id)initWithEvents:(GHEvents *)theEvents;
- (void)openEventItem:(id)theEventItem;
- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;
@end