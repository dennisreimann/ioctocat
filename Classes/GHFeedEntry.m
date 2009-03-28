#import "GHFeedEntry.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, date, linkURL, title, content, authorName;

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[entryID release];
	[eventType release];
	[date release];
	[linkURL release];
	[title release];
	[content release];
	[authorName release];
    [super dealloc];
}

@end
