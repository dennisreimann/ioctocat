#import "GHNetwork.h"
#import "iOctocat.h"


@implementation GHNetwork

@synthesize description;
@synthesize name;
@synthesize networkURL;
@synthesize owner;
@synthesize repository;

- (void)dealloc {
    [repository release];
    [description release];
    [owner release];
    [name release];
    [networkURL release];
    [super dealloc];
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:owner];
}

@end
