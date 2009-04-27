#import "GHResource.h"


@implementation GHResource

@synthesize status;

- (BOOL)isLoading {
	return status == GHResourceStatusLoading;
}

- (BOOL)isLoaded {
	return status == GHResourceStatusLoaded;
}

@end
