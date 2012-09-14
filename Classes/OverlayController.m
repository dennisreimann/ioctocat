#import "OverlayController.h"


@interface OverlayController ()
@property(nonatomic,retain)id target;
@end


@implementation OverlayController

@synthesize target;

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super initWithNibName:@"Overlay" bundle:nil];
	self.target = theTarget;
	selector = theSelector;
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[target performSelector:selector withObject:touches];
}

- (void)dealloc {
	[target release], target = nil;
	[super dealloc];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
