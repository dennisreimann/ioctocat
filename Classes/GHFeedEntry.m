#import "GHFeedEntry.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, date, linkURL, title, content, authorName;

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeedEntry entryID:'%@' eventType:'%@' title:'%@' authorName:'%@'>", entryID, eventType, title, authorName];
}

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
