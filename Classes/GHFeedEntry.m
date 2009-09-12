#import "GHFeedEntry.h"
#import "GHRepository.h"
#import "iOctocatAppDelegate.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, eventItem, date, linkURL, title, content, authorName;

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeedEntry entryID:'%@' eventType:'%@' title:'%@' authorName:'%@'>", entryID, eventType, title, authorName];
}

- (void)dealloc {
	[entryID release];
	[eventType release];
	[eventItem release];
	[date release];
	[linkURL release];
	[title release];
	[content release];
	[authorName release];
    [super dealloc];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:authorName];
}

- (id)eventItem {
	if (eventItem) return eventItem;
	if ([eventType isEqualToString:@"fork"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" forked "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
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
	} else if ([eventType isEqualToString:@"watch"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" started watching "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"push"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" at "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"create"]) {
		NSString *owner;
		NSString *name;
		// Tag or Branch
		if ([title rangeOfString:@" tag "].location != NSNotFound || [title rangeOfString:@" branch "].location != NSNotFound) {
			NSArray *comps1 = [title componentsSeparatedByString:@" at "];
			NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
			owner = [comps2 objectAtIndex:0];
			name = [comps2 objectAtIndex:1];
		}
		// Repository
		else {
			NSArray *comps1 = [title componentsSeparatedByString:@" "];
			owner = [comps1 objectAtIndex:0];
			name = [comps1 objectAtIndex:3];
		}
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	} else if ([eventType isEqualToString:@"wiki"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" in the "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@" wiki"];
		NSArray *comps3 = [[comps2 objectAtIndex:0] componentsSeparatedByString:@"/"];
		NSString *owner = [comps3 objectAtIndex:0];
		NSString *name = [comps3 objectAtIndex:1];
		self.eventItem = [[[GHRepository alloc] initWithOwner:owner andName:name] autorelease];
	}
	return eventItem;
}

@end
