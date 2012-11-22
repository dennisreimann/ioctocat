#import "GHEvent.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHPullRequest.h"
#import "GHRepoComment.h"
#import "GHIssueComment.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"


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
@synthesize comment;
@synthesize commits;
@synthesize user;
@synthesize otherUser;
@synthesize organization;
@synthesize repository;
@synthesize otherRepository;
@synthesize pullRequest;
@synthesize payload;
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
	return [NSString stringWithFormat:@"<GHEvent eventID:'%@' eventType:'%@' actorLogin:'%@' repoName:'%@'>", eventID, eventType, user.login, repoName];
}

- (void)dealloc {
	[eventID release], eventID = nil;
	[eventType release], eventType = nil;
	[date release], date = nil;
	[gist release], gist = nil;
	[issue release], issue = nil;
	[pages release], pages = nil;
	[comment release], comment = nil;
	[commits release], commits = nil;
	[repository release], repository = nil;
	[user release], user = nil;
	[otherUser release], otherUser = nil;
	[organization release], organization = nil;
	[otherRepository release], otherRepository = nil;
	[pullRequest release], pullRequest = nil;
	[payload release], payload = nil;
	[repoName release], repoName = nil;
	[otherRepoName release], otherRepoName = nil;
	[_title release], _title = nil;
	[_content release], _content = nil;
	[super dealloc];
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
	self.payload = [theDict valueForKeyPath:@"payload"];

	NSString *actorLogin = [theDict valueForKeyPath:@"actor.login"];
	NSString *orgLogin = [theDict valueForKeyPath:@"org.login"];

	// User
	if (![actorLogin isEmpty]) {
		self.user = [[iOctocat sharedInstance] userWithLogin:actorLogin];
		NSString *avatarURL = [theDict valueForKeyPath:@"actor.avatar_url"];
		if (!self.user.gravatarURL && ![avatarURL isEmpty]) {
			self.user.gravatarURL = [NSURL smartURLFromString:avatarURL];
		}
	}

	// Organization
	if (![orgLogin isEmpty]) {
		self.organization = [[iOctocat sharedInstance] organizationWithLogin:orgLogin];
		NSString *avatarURL = [theDict valueForKeyPath:@"org.avatar_url"];
		if (!self.organization.gravatarURL && ![avatarURL isEmpty]) {
			self.organization.gravatarURL = [NSURL smartURLFromString:avatarURL];
		}
	}

	// Other user
	NSString *otherUserLogin = nil;
	NSString *otherUserAvatarURL = nil;
	NSDictionary *otherUserDict = [payload valueForKey:@"target"];
	if (!otherUserDict) otherUserDict = [payload valueForKey:@"member"];
	if (!otherUserDict) otherUserDict = [payload valueForKey:@"user"];
	if (!otherUserDict && !self.organization && [eventType isEqualToString:@"WatchEvent"]) {
		// use repo owner as fallback
		otherUserLogin = [[[theDict valueForKeyPath:@"repo.name"]  componentsSeparatedByString:@"/"] objectAtIndex:0];
	} else if (otherUserDict) {
		otherUserLogin = [otherUserDict valueForKey:@"login"];
		otherUserAvatarURL = [otherUserDict valueForKey:@"avatar_url"];
	}
	if (![otherUserLogin isEmpty]) {
		self.otherUser = [[iOctocat sharedInstance] userWithLogin:otherUserLogin];
		if (!self.otherUser.gravatarURL && ![otherUserAvatarURL isEmpty]) {
			self.otherUser.gravatarURL = [NSURL smartURLFromString:otherUserAvatarURL];
		}
	}

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
	NSInteger issueNumber = [[payload valueForKeyPath:@"issue.number"] integerValue];
	if (issueNumber > 0) {
		self.issue = [GHIssue issueWithRepository:self.repository];
		self.issue.num = issueNumber;
		[self.issue setValues:[payload valueForKey:@"issue"]];
	}

	// Pull Request
	NSDictionary *pullPayload = [payload valueForKey:@"pull_request"];
	if (!pullPayload) pullPayload = [payload valueForKeyPath:@"issue.pull_request"];
	// this check is somehow hacky, but the API provides empty pull_request
	// urls in case there is no pull request associated with an issue
	if (pullPayload && ![[pullPayload valueForKey:@"html_url"] isKindOfClass:[NSNull class]]) {
		NSInteger pullNumber = [[pullPayload valueForKey:@"number"] integerValue];
		if (!pullNumber) pullNumber = issue.num;
		self.pullRequest = [GHPullRequest pullRequestWithRepository:self.repository];
		self.pullRequest.num = pullNumber;
	}

	// Issue Comment (which might also be a pull request comment)
	if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		self.comment = [GHIssueComment commentWithParent:issueCommentParent andDictionary:[payload valueForKey:@"comment"]];
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

	// Commit Comment
	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		self.comment = [GHRepoComment commentWithRepo:self.repository andDictionary:[payload valueForKey:@"comment"]];
		if (!self.commits) {
			GHCommit *commit = [GHCommit commitWithRepo:self.repository andSha:[payload valueForKeyPath:@"comment.commit_id"]];
			self.commits = [NSArray arrayWithObject:commit];
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
}

- (NSString *)title {
	if (_title) return _title;

	if ([eventType isEqualToString:@"CommitCommentEvent"]) {
		NSString *commitId = [self shortenSha:[payload valueForKeyPath:@"comment.commit_id"]];
		self._title = [NSString stringWithFormat:@"%@ commented on %@ at %@", user.login, commitId, repoName];
	}

	else if ([eventType isEqualToString:@"CreateEvent"]) {
		NSString *ref = [payload valueForKey:@"ref"];
		NSString *refType = [payload valueForKey:@"ref_type"];
		if ([refType isEqualToString:@"repository"]) { // created repository
			self._title = [NSString stringWithFormat:@"%@ created %@ %@", user.login, refType, repository.name];
		} else { // created branch or tag
			self._title = [NSString stringWithFormat:@"%@ created %@ %@ at %@", user.login, refType, ref, repoName];
		}
	}

	else if ([eventType isEqualToString:@"DeleteEvent"]) {
		NSString *ref = [payload valueForKey:@"ref"];
		NSString *refType = [payload valueForKey:@"ref_type"];
		self._title = [NSString stringWithFormat:@"%@ deleted %@ %@ at %@", user.login, refType, ref, repoName];
	}

	else if ([eventType isEqualToString:@"DownloadEvent"]) {
		NSString *name = [payload valueForKeyPath:@"download.name"];
		self._title = [NSString stringWithFormat:@"%@ created download %@ at %@", user.login, name, repository.name];
	}

	else if ([eventType isEqualToString:@"FollowEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ started following %@", user.login, otherUser.login];
	}

	else if ([eventType isEqualToString:@"ForkEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ forked %@ to %@", user.login, repository.repoId, otherRepository.repoId];
	}

	else if ([eventType isEqualToString:@"ForkApplyEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ applied a patch to %@", user.login, repository.repoId];
	}

	else if ([eventType isEqualToString:@"GistEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		if ([action isEqualToString:@"create"]) {
			action = @"created";
		} else if ([action isEqualToString:@"update"]) {
			action = @"updated";
		}
		self._title = [NSString stringWithFormat:@"%@ %@ gist %@", user.login, action, gist.gistId];
	}

	else if ([eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = [pages objectAtIndex:0];
		NSString *action = [firstPage valueForKey:@"action"];
		self._title = [NSString stringWithFormat:@"%@ %@ the %@ wiki", user.login, action, repository.repoId];
	}

	else if ([eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		NSString *parentType = self.pullRequest ? @"pull request" : @"issue";
		NSUInteger num = [(GHIssue *)issueCommentParent num];
		self._title = [NSString stringWithFormat:@"%@ commented on %@ %@#%d", user.login, parentType, repoName, num];
	}

	else if ([eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		self._title = [NSString stringWithFormat:@"%@ %@ issue %@#%d", user.login, action, repoName, issue.num];
	}

	else if ([eventType isEqualToString:@"MemberEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ added %@ to %@", user.login, otherUser.login, repoName];
	}

	else if ([eventType isEqualToString:@"PublicEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ open sourced %@", user.login, repository.repoId];
	}

	else if ([eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = [payload valueForKey:@"action"];
		if ([action isEqualToString:@"closed"]) action = @"merged";
		self._title = [NSString stringWithFormat:@"%@ %@ pull request %@#%d", user.login, action, repoName, pullRequest.num];
	}

	else if ([eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ commented on pull request %@#%d", user.login, repoName, pullRequest.num];
	}

	else if ([eventType isEqualToString:@"PushEvent"]) {
		NSString *ref = [self shortenRef:[payload valueForKey:@"ref"]];
		self._title = [NSString stringWithFormat:@"%@ pushed to %@ at %@", user.login, ref, repoName];
	}

	else if ([eventType isEqualToString:@"TeamAddEvent"]) {
		NSString *teamName = [payload valueForKeyPath:@"team.name"];
		// for older events the team may not be set, so leave out to which team the user was added
		NSString *teamInfo = teamName ? [NSString stringWithFormat:@" to %@", teamName] : @"";
		self._title = [NSString stringWithFormat:@"%@ added %@%@", user.login, otherUser.login, teamInfo];
	}

	else if ([eventType isEqualToString:@"WatchEvent"]) {
		self._title = [NSString stringWithFormat:@"%@ starred %@", user.login, repoName];
	}

	return _title;
}

- (NSString *)content {
	if (_content) return _content;

	if ([eventType isEqualToString:@"CommitCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}

	else if ([eventType isEqualToString:@"CreateEvent"]) {
		NSString *refType = [payload valueForKey:@"ref_type"];
		self._content = [refType isEqualToString:@"repository"] ? repository.descriptionText : @"";
	}

	else if ([eventType isEqualToString:@"ForkEvent"]) {
		self._content = otherRepository.descriptionText;
	}

	else if ([eventType isEqualToString:@"GistEvent"]) {
		self._content = gist.descriptionText;
	}

	else if ([eventType isEqualToString:@"GollumEvent"]) {
		self._content = @""; // TODO
	}

	else if ([eventType isEqualToString:@"IssueCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}

	else if ([eventType isEqualToString:@"IssuesEvent"]) {
		self._content = issue.title;
	}

	else if ([eventType isEqualToString:@"PullRequestEvent"]) {
		self._content = pullRequest.title;
	}

	else if ([eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self._content = [payload valueForKeyPath:@"comment.body"];
	}

	else if ([eventType isEqualToString:@"PushEvent"]) {
		self._content = @""; // TODO
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
