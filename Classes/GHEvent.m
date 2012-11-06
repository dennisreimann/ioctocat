#import "GHEvent.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"


@interface GHEvent ()
@property(nonatomic,retain)NSString *_title;
@property(nonatomic,retain)NSString *_content;
- (NSString *)shortenSha:(NSString *)longSha;
- (NSString *)shortenRef:(NSString *)longRef;
@end

@implementation GHEvent

@synthesize eventID;
@synthesize eventType;
@synthesize date;
@synthesize gist;
@synthesize issue;
@synthesize pages;
@synthesize commits;
@synthesize repository;
@synthesize otherRepository;
@synthesize payload;
@synthesize actorLogin;
@synthesize otherUserLogin;
@synthesize orgLogin;
@synthesize repoName;
@synthesize otherRepoName;
@synthesize read;
@synthesize _title;
@synthesize _content;

+ (id)eventWithDict:(NSDictionary *)theDict {
	return [[[self.class alloc] initWithDict:theDict] autorelease];
}

- (id)initWithDict:(NSDictionary *)theDict {
    [super init];
	self.read = NO;
	[self setValues:theDict];
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHEvent eventID:'%@' eventType:'%@' actorLogin:'%@' repoName:'%@'>", eventID, eventType, actorLogin, repoName];
}

- (void)dealloc {
	[eventID release], eventID = nil;
	[eventType release], eventType = nil;
	[date release], date = nil;
	[gist release], gist = nil;
	[issue release], issue = nil;
	[pages release], pages = nil;
	[commits release], commits = nil;
	[repository release], repository = nil;
	[otherRepository release], otherRepository = nil;
	[payload release], payload = nil;
	[actorLogin release], actorLogin = nil;
	[otherUserLogin release], otherUserLogin = nil;
	[orgLogin release], orgLogin = nil;
	[repoName release], repoName = nil;
	[otherRepoName release], otherRepoName = nil;
	[_title release], _title = nil;
	[_content release], _content = nil;
    [super dealloc];
}

- (GHUser *)user {
	return actorLogin ? [[iOctocat sharedInstance] userWithLogin:actorLogin] : nil;
}

- (GHUser *)otherUser {
	return otherUserLogin ? [[iOctocat sharedInstance] userWithLogin:otherUserLogin] : nil;
}

- (GHOrganization *)organization {
	return orgLogin ? [[iOctocat sharedInstance] organizationWithLogin:orgLogin] : nil;
}

- (NSString *)extendedEventType {
	if ([eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		return [action isEqualToString:@"closed"] ? @"IssuesClosedEvent" : @"IssuesOpenedEvent";
	} else if ([eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		if ([action isEqualToString:@"synchronize"]) {
			return @"PullRequestSynchronizeEvent";
		}
		return [action isEqualToString:@"closed"] ? @"PullRequestClosedEvent" : @"PullRequestOpenedEvent";
	}
    return eventType;
}

- (void)setValues:(id)theDict {
	self.eventID = [theDict valueForKey:@"id"];
	self.eventType = [theDict valueForKey:@"type"];
	self.date = [iOctocat parseDate:[theDict valueForKey:@"created_at"]];
	self.actorLogin = [theDict valueForKeyPath:@"actor.login"];
	self.orgLogin = [theDict valueForKeyPath:@"org.login"];
	self.payload = [theDict valueForKeyPath:@"payload"];
	
	// Repository
	self.repoName = [theDict valueForKeyPath:@"repo.name"];
	NSArray *_repoParts = [repoName componentsSeparatedByString:@"/"];
	NSString *_repoOwner = [_repoParts objectAtIndex:0];
	NSString *_repoName = [_repoParts objectAtIndex:1];
	if (!!_repoOwner && !!_repoName && ![_repoOwner isEmpty] && ![_repoName isEmpty]) {
		self.repository = [GHRepository repositoryWithOwner:_repoOwner andName:_repoName];
		self.repository.descriptionText = [payload valueForKey:@"description"];
	}
	
	// Other Repository
	self.otherRepoName = [payload valueForKeyPath:@"forkee.full_name"];
	_repoParts = [otherRepoName componentsSeparatedByString:@"/"];
	_repoOwner = [_repoParts objectAtIndex:0];
	_repoName = [_repoParts objectAtIndex:1];
	if (!!_repoOwner && !!_repoName && ![_repoOwner isEmpty] && ![_repoName isEmpty]) {
		self.otherRepository = [GHRepository repositoryWithOwner:_repoOwner andName:_repoName];
		self.otherRepository.descriptionText = [payload valueForKeyPath:@"forkee.description"];
	}
	
	// Issue
	// TODO: Handle Pull Requests differently
	NSInteger issueNumber = [[payload valueForKeyPath:@"issue.number"] integerValue];
	if (!issueNumber || issueNumber < 0) issueNumber = [[payload valueForKeyPath:@"pull_request.number"] integerValue];
	if (issueNumber > 0) {
		self.issue = [GHIssue issueWithRepository:self.repository];
		self.issue.num = issueNumber;
	}
	
	// Gist
	NSString *gistId = [payload valueForKeyPath:@"gist.id"];
	if (gistId) {
		self.gist = [GHGist gistWithId:gistId];
	}
	
	// Commits
	NSArray *_commits = [payload valueForKey:@"commits"];
	if (_commits) {
		self.commits = [NSMutableArray arrayWithCapacity:_commits.count];
		for (NSDictionary *commitDict in _commits) {
			NSString *theSha = [commitDict valueForKey:@"sha"];
			GHCommit *commit = [GHCommit commitWithRepo:self.repository andSha:theSha];
			commit.message = [commitDict valueForKey:@"message"];
			[self.commits addObject:commit];
		}
	}
	
	// Wiki
	NSArray *_pages = [payload valueForKey:@"pages"];
	if (_pages) {
		self.pages = [NSMutableArray arrayWithCapacity:_pages.count];
		for (NSDictionary *pageDict in _pages) {
			[self.pages addObject:pageDict];
		}
	}
	
	// User
	self.otherUserLogin = [payload valueForKeyPath:@"target.login"];
	if (!self.otherUserLogin) self.otherUserLogin = [payload valueForKeyPath:@"member.login"];
	if (!self.otherUserLogin) self.otherUserLogin = [payload valueForKeyPath:@"user.login"];
}

- (NSString *)title {
	if (_title) return _title;
	
	if ([eventType isEqualToString:@"CommitCommentEvent"]) {
		NSString *commitId = [self shortenSha:[payload valueForKeyPath:@"comment.commit_id"]];
		self._title = [NSString stringWithFormat:@"%@ commented on %@ at %@", actorLogin, commitId, repoName];
	}
	
	else if ([eventType isEqualToString:@"CreateEvent"]) {
		NSString *ref = [payload valueForKey:@"ref"];
		NSString *refType = [payload valueForKey:@"ref_type"];
		if ([refType isEqualToString:@"repository"]) { // created repository
			self._title = [NSString stringWithFormat:@"%@ created %@ %@", actorLogin, refType, repository.name];
		} else { // created branch or tag
			self._title = [NSString stringWithFormat:@"%@ created %@ %@ at %@", actorLogin, refType, ref, repoName];
		}
	}
	
	else if ([eventType isEqualToString:@"DeleteEvent"]) {
		NSString *ref = [payload valueForKey:@"ref"];
		NSString *refType = [payload valueForKey:@"ref_type"];
		self._title = [NSString stringWithFormat:@"%@ deleted %@ %@ at %@", actorLogin, refType, ref, repoName];
	}
	
	else if ([eventType isEqualToString:@"DownloadEvent"]) {
		NSString *name = [payload valueForKeyPath:@"download.name"];
		self._title = [NSString stringWithFormat:@"%@ created download %@ at %@", actorLogin, name, repository.name];
	}
	
	else if ([eventType isEqualToString:@"FollowEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ started following %@", actorLogin, otherUserLogin];
	}
	
	else if ([eventType isEqualToString:@"ForkEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ forked %@ to %@", actorLogin, repository.repoId, otherRepository.repoId];
	}
	
	else if ([eventType isEqualToString:@"ForkApplyEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ applied a patch to %@", actorLogin, repository.repoId];
	}
	
	else if ([eventType isEqualToString:@"GistEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		if ([action isEqualToString:@"create"]) {
			action = @"created";
		} else if ([action isEqualToString:@"update"]) {
			action = @"updated";
		}
		self._title = [NSString stringWithFormat:@"%@ %@ gist %@", actorLogin, action, gist.gistId];
	}
	
	else if ([eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = [pages objectAtIndex:0];
		NSString *action = [firstPage valueForKey:@"action"];
		self._title = [NSString stringWithFormat:@"%@ %@ the %@ wiki", actorLogin, action, repository.repoId];
	}
	
	else if ([eventType isEqualToString:@"IssueCommentEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ commented on %@#%d", actorLogin, repoName, issue.num];
	}
	
	else if ([eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		self._title = [NSString stringWithFormat:@"%@ %@ issue %@#%d", actorLogin, action, repoName, issue.num];
	}
	
	else if ([eventType isEqualToString:@"MemberEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ added %@ to %@", actorLogin, otherUserLogin, repoName];
	}
	
	else if ([eventType isEqualToString:@"PublicEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ open sourced %@", actorLogin, repository.repoId];
	}
	
	else if ([eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		self._title = [NSString stringWithFormat:@"%@ %@ pull request %@#%d", actorLogin, action, repoName, issue.num];
	}
	
	else if ([eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ commented on issue %@#%d", actorLogin, repoName, issue.num];
	}
	
	else if ([eventType isEqualToString:@"PushEvent"]) {
		NSString *ref = [self shortenRef:[payload valueForKey:@"ref"]];
		self._title = [NSString stringWithFormat:@"%@ pushed to %@ at %@", actorLogin, ref, repoName];
	}
	
	else if ([eventType isEqualToString:@"TeamAddEvent"]) {
		NSString *teamName = [payload valueForKeyPath:@"team.name"];
		// for older events the team may not be set, so leave out to which team the user was added
		NSString *teamInfo = teamName ? [NSString stringWithFormat:@" to %@", teamName] : @"";
		self._title = [NSString stringWithFormat:@"%@ added %@%@", actorLogin, otherUserLogin, teamInfo];
	}
	
	else if ([eventType isEqualToString:@"WatchEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ starred %@", actorLogin, repoName];
	}
	
    return _title;
}

- (NSString *)content {
    if (_content) return _content;
	
	if ([eventType isEqualToString:@"CommitCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}
	
	else if ([eventType isEqualToString:@"CreateEvent"]) {
		self._content = [payload valueForKey:@"description"];
	}
	
	else if ([eventType isEqualToString:@"DeleteEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"ForkEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"GistEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"GollumEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"IssueCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}
	
	else if ([eventType isEqualToString:@"IssuesEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"PublicEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"PullRequestEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}
	
	else if ([eventType isEqualToString:@"PushEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"TeamAddEvent"]) {
		self._content = @"";
	}
	
	else if ([eventType isEqualToString:@"WatchEvent"]) {
		self._content = @"";
	}
	
    return _content;
}

- (NSString *)shortenSha:(NSString *)longSha {
	return [longSha substringToIndex:6];
}

- (NSString *)shortenRef:(NSString *)longRef {
	return [longRef lastPathComponent];
}

@end
