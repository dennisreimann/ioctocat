#import "GHFeed.h"


@implementation GHFeed

@synthesize url, entries;

- (id)initWithURL:(NSURL *)theURL {
	if (self = [super init]) {
		self.url = theURL;
		self.entries = [NSMutableArray array];
	}
	return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[url release];
	[entries release];
    [super dealloc];
}

@end
