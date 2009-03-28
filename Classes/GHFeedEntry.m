#import "GHFeedEntry.h"


@implementation GHFeedEntry

@synthesize entryID, date, linkURL, title, content, authorName;

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[entryID release];
	[date release];
	[linkURL release];
	[title release];
	[content release];
	[authorName release];
    [super dealloc];
}

@end
