#import "GHFeedEntry.h"
#import "GHUser.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, date, linkURL, title, content, user, feed;

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeedEntry entryID:'%@' eventType:'%@' title:'%@' user:'%@'>", entryID, eventType, title, user];
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
	[user release];
	[feed release];
    [super dealloc];
}

@end
