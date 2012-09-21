#import "GHFeedEntry.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "iOctocat.h"


@implementation GHFeedEntry

@synthesize entryID;
@synthesize eventType;
@synthesize eventItem;
@synthesize date;
@synthesize linkURL;
@synthesize title;
@synthesize content;
@synthesize authorName;
@synthesize read;

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

- (GHOrganization *)organization {
	return [[iOctocat sharedInstance] organizationWithLogin:authorName];
}

- (id)eventItem {
	if (eventItem) return eventItem;
	@try {
		NSString *path = [linkURL path];
		NSArray *comps = [path componentsSeparatedByString:@"/"];
		if ([eventType isEqualToString:@"fork"] || [eventType isEqualToString:@"pull_request"] || [eventType isEqualToString:@"watch"] || [eventType isEqualToString:@"star"] || [eventType isEqualToString:@"push"] || [eventType isEqualToString:@"wiki"]) {
			NSString *owner = [comps objectAtIndex:1];
			NSString *name = [comps objectAtIndex:2];
			self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
		} else if ([eventType isEqualToString:@"issue"] || [eventType isEqualToString:@"issue_comment"]) {
			NSString *owner = [comps objectAtIndex:1];
			NSString *name = [comps objectAtIndex:2];
			NSInteger num = [[comps lastObject] intValue];
			GHRepository *repository = [GHRepository repositoryWithOwner:owner andName:name];
			GHIssue *issue = [GHIssue issueWithRepository:repository];
			issue.num = num;
			self.eventItem = issue;
		} else if ([eventType isEqualToString:@"commit"] || [eventType isEqualToString:@"commit_comment"]) {
			NSString *owner = [comps objectAtIndex:1];
			NSString *name = [comps objectAtIndex:2];
			NSString *commitID = [comps objectAtIndex:4];
			GHRepository *repository = [GHRepository repositoryWithOwner:owner andName:name];
			self.eventItem = [GHCommit commitWithRepository:repository andCommitID:commitID];
		} else if ([eventType isEqualToString:@"follow"]) {
			NSArray *comps1 = [title componentsSeparatedByString:@" following "];
			NSString *username = [comps1 objectAtIndex:1];
			self.eventItem = [[iOctocat sharedInstance] userWithLogin:username];
		} else if ([eventType isEqualToString:@"team_add"] || [eventType isEqualToString:@"member"]) {
			NSArray *comps1 = [title componentsSeparatedByString:@" added "];
			NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@" to "];
			NSString *username = [comps2 objectAtIndex:0];
			self.eventItem = [[iOctocat sharedInstance] userWithLogin:username];
		} else if ([eventType isEqualToString:@"download"]) {
			NSArray *comps1 = [title componentsSeparatedByString:@" to "];
			NSArray *comps2 = [[comps1 objectAtIndex:1] componentsSeparatedByString:@"/"];
			NSString *owner = [comps2 objectAtIndex:0];
			NSString *name = [comps2 objectAtIndex:1];
			self.eventItem = [GHRepository repositoryWithOwner:owner andName:name];
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
		}
	}
	@catch (id theException) {
		eventType = nil;
	}
	return eventItem;
}

@end
