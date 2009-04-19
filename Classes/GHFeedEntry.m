#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "iOctocatAppDelegate.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, eventItem, date, linkURL, title, content, authorName, feed;

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeedEntry entryID:'%@' eventType:'%@' title:'%@' authorName:'%@'>", entryID, eventType, title, authorName];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:authorName];
}

- (id)eventItem {
	if (eventItem) return eventItem;
	if ([eventType isEqualToString:@"fork"]) {
	} else if ([eventType isEqualToString:@"issues"] || [eventType isEqualToString:@"comment"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" on "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"follow"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" following "];
		NSString *username = [comps1 objectAtIndex:1];
		iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.eventItem = [appDelegate userWithLogin:username];
	} else if ([eventType isEqualToString:@"commit"]) {
	} else if ([eventType isEqualToString:@"watch"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" started watching "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"delete"]) {
	} else if ([eventType isEqualToString:@"merge"]) {
	} else if ([eventType isEqualToString:@"member"]) {
	} else if ([eventType isEqualToString:@"push"] || [eventType isEqualToString:@"create"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" at "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"gist"]) {
	} else if ([eventType isEqualToString:@"wiki"]) {
	}
	return eventItem;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[entryID release];
	[eventType release];
	[eventItem release];
	[date release];
	[linkURL release];
	[title release];
	[content release];
	[authorName release];
	[feed release];
    [super dealloc];
}

@end
