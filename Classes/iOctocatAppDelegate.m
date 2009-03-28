#import "iOctocatAppDelegate.h"
#import "RootViewController.h"


@implementation iOctocatAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:[navigationController view]];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
