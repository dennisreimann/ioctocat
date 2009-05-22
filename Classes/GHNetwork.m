#import "GHNetwork.h"
#import "iOctocatAppDelegate.h"


@implementation GHNetwork

@synthesize description, name, networkURL, owner, repository;

- (void)dealloc {
    [repository release];
    [description release];
    [owner release];
    [name release];
    [networkURL release];
    [super dealloc];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:owner];
}

@end
