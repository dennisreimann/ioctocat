#import <UIKit/UIKit.h>
#import "EventsController.h"


@class GHFeed, GHUser, EventCell;

@interface MyEventsController : EventsController

@property(nonatomic,weak)IBOutlet UISegmentedControl *feedControl;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *organizationItem;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (BOOL)refreshCurrentFeedIfRequired;
- (IBAction)switchChanged:(id)sender;
- (IBAction)selectOrganization:(id)sender;

@end