#import "GHResource.h"


@implementation GHResource

@synthesize status, error;

- (BOOL)isLoading {
	return status == GHResourceStatusLoading;
}

- (BOOL)isLoaded {
	return status == GHResourceStatusLoaded;
}

- (void) dealloc {
	[error release];
	[super dealloc];
}

@end
