#import "OverlayController.h"


@implementation OverlayController

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super initWithNibName:@"Overlay" bundle:nil];
	target = [theTarget retain];
	selector = theSelector;
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[target performSelector:selector withObject:touches];
}

- (void)dealloc {
	[target release];
	[super dealloc];
}

@end
