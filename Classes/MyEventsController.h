#import <UIKit/UIKit.h>
#import "EventsController.h"


@class GHFeed, GHUser, EventCell;

@interface MyEventsController : EventsController
@property(nonatomic,strong)IBOutlet UISegmentedControl *feedControl;

- (id)initWithUser:(GHUser *)theUser;
- (BOOL)refreshCurrentFeedIfRequired;
- (IBAction)switchChanged:(id)sender;
@end