#import "GHFeedEntry.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "iOctocat.h"


@implementation GHFeedEntry

@synthesize entryID, eventType, eventItem, date, linkURL, title, content, authorName, read;

- (id)init {
    [super init];
	read = NO;
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeedEntry entryID:'%@' eventType:'%@' title:'%@' authorName:'%@' date:'%@'>", entryID, eventType, title, authorName, date];
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
	return [[iOctocat sharedInstance] userWithLogin:authorName];
}

- (id)eventItem {
	if (eventItem) return eventItem;
	if ([eventType isEqualToString:@"fork"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" forked "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"issue"]) {
		NSArray *comps = [title componentsSeparatedByString:@" on "];
		NSArray *issueComps = [[comps objectAtIndex:0] componentsSeparatedByString:@" "];
		NSInteger num = [[issueComps lastObject] intValue];
		NSArray *repoComps = [[comps objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [repoComps objectAtIndex:0];
		NSString *name = [repoComps objectAtIndex:1];
		GHRepository *repository = [GHRepository repositoryWithOwner:owner andName:name];
		GHIssue *issue = [[GHIssue alloc] initWithRepository:repository];
		issue.num = num;
		self.eventItem = issue;
		[issue release];
	} else if ([eventType isEqualToString:@"pull_request"]) {
		NSArray *comps = [title componentsSeparatedByString:@" on "];
		// NSArray *reqComps = [[comps objectAtIndex:0] componentsSeparatedByString:@" "];
		// NSInteger num = [[issueComps lastObject] intValue];
		NSArray *repoComps = [[comps objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [repoComps objectAtIndex:0];
		NSString *name = [repoComps objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"comment"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" on "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"follow"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" following "];
		NSString *username = [comps1 objectAtIndex:1];
		self.eventItem = [[iOctocat sharedInstance] userWithLogin:username];
	} else if ([eventType isEqualToString:@"watch"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" started watching "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"push"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" at "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
		NSString *owner = [comps2 objectAtIndex:0];
		NSString *name = [comps2 objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"commit"]) {
		NSString *path = [linkURL path];
		NSArray *comps = [path componentsSeparatedByString:@"/"];
		NSString *owner = [comps objectAtIndex:1];
		NSString *name = [comps objectAtIndex:2];
		NSString *sha = [comps objectAtIndex:4];
		GHRepository *repository = [GHRepository repositoryWithOwner:owner andName:name];
		self.eventItem = [[[GHCommit alloc] initWithRepository:repository andCommitID:sha] autorelease];
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
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	} else if ([eventType isEqualToString:@"wiki"]) {
		NSArray *comps1 = [title componentsSeparatedByString:@" in the "];
		NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@" wiki"];
		NSArray *comps3 = [[comps2 objectAtIndex:0] componentsSeparatedByString:@"/"];
		NSString *owner = [comps3 objectAtIndex:0];
		NSString *name = [comps3 objectAtIndex:1];
		self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
	}
	return eventItem;
}

@end
