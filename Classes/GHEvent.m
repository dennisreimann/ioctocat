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
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHEvent ()
- (NSString *)shortenMessage:(NSString *)longMessage;
- (NSString *)shortenSha:(NSString *)longSha;
- (NSString *)shortenRef:(NSString *)longRef;
@end

@implementation GHEvent

+ (id)eventWithDict:(NSDictionary *)theDict {
	return [[self.class alloc] initWithDict:theDict];
}

- (id)initWithDict:(NSDictionary *)theDict {
	self = [super init];
	if (self) {
		self.read = NO;
		[self setValues:theDict];
	}
	return self;
}

- (NSString *)extendedEventType {
	if ([self.eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = [self.payload valueForKey:@"action"];
		return [action isEqualToString:@"closed"] ? @"IssuesClosedEvent" : @"IssuesOpenedEvent";
	} else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = [self.payload valueForKey:@"action"];
		if ([action isEqualToString:@"synchronize"]) {
			return @"PullRequestSynchronizeEvent";
		}
		return [action isEqualToString:@"closed"] ? @"PullRequestClosedEvent" : @"PullRequestOpenedEvent";
	}
	return self.eventType;
}

- (BOOL)isCommentEvent {
	return [self.eventType hasSuffix:@"CommentEvent"];
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
	NSDictionary *otherUserDict = [self.payload valueForKey:@"target"];
	if (!otherUserDict) otherUserDict = [self.payload valueForKey:@"member"];
	if (!otherUserDict) otherUserDict = [self.payload valueForKey:@"user"];
	if (!otherUserDict && !self.organization && [self.eventType isEqualToString:@"WatchEvent"]) {
		// use repo owner as fallback
		otherUserLogin = [[[theDict valueForKeyPath:@"repo.name"] componentsSeparatedByString:@"/"] objectAtIndex:0];
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
	NSArray *rParts = [self.repoName componentsSeparatedByString:@"/"];
	NSString *rOwner = [rParts objectAtIndex:0];
	NSString *rName = [rParts objectAtIndex:1];
	if (!!rOwner && !!rName && ![rOwner isEmpty] && ![rName isEmpty]) {
		self.repository = [GHRepository repositoryWithOwner:rOwner andName:rName];
		self.repository.descriptionText = [self.payload valueForKey:@"description"];
	}

	// Other Repository
	self.otherRepoName = [self.payload valueForKeyPath:@"forkee.full_name"];
	rParts = [self.otherRepoName componentsSeparatedByString:@"/"];
	rOwner = [rParts objectAtIndex:0];
	rName = [rParts objectAtIndex:1];
	if (!!rOwner && !!rName && ![rOwner isEmpty] && ![rName isEmpty]) {
		self.otherRepository = [GHRepository repositoryWithOwner:rOwner andName:rName];
		self.otherRepository.descriptionText = [self.payload valueForKeyPath:@"forkee.description"];
	}

	// Issue
	NSInteger issueNumber = [[self.payload valueForKeyPath:@"issue.number"] integerValue];
	if (issueNumber > 0) {
		self.issue = [GHIssue issueWithRepository:self.repository];
		self.issue.num = issueNumber;
		[self.issue setValues:[self.payload valueForKey:@"issue"]];
	}

	// Pull Request
	NSDictionary *pullPayload = [self.payload valueForKey:@"pull_request"];
	if (!pullPayload) pullPayload = [self.payload valueForKeyPath:@"issue.pull_request"];
	// this check is somehow hacky, but the API provides empty pull_request
	// urls in case there is no pull request associated with an issue
	if (pullPayload && ![[pullPayload valueForKey:@"html_url" defaultsTo:@""] isEmpty]) {
		NSInteger pullNumber = [[pullPayload valueForKey:@"number"] integerValue];
		if (!pullNumber) pullNumber = self.issue.num;
		self.pullRequest = [GHPullRequest pullRequestWithRepository:self.repository];
		self.pullRequest.num = pullNumber;
		self.pullRequest.title = [self.payload valueForKeyPath:@"pull_request.title"];
	}

	// Issue Comment (which might also be a pull request comment)
	if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		self.comment = [GHIssueComment commentWithParent:issueCommentParent
										   andDictionary:[self.payload valueForKey:@"comment"]];
	}

	// Gist
	NSString *gistId = [self.payload valueForKeyPath:@"gist.id"];
	if (gistId) {
		self.gist = [GHGist gistWithId:gistId];
		[self.gist setValues:[self.payload valueForKey:@"gist"]];
	}

	// Commits
	NSArray *commits = [self.payload valueForKey:@"commits"];
	if (commits) {
		self.commits = [NSMutableArray arrayWithCapacity:commits.count];
		for (NSDictionary *commitDict in commits) {
			NSString *theSha = [commitDict valueForKey:@"sha"];
			GHCommit *commit = [GHCommit commitWithRepo:self.repository andSha:theSha];
			commit.author = self.user;
			commit.message = [commitDict valueForKey:@"message" defaultsTo:@""];
			[self.commits addObject:commit];
		}
	}

	// Commit Comment
	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		self.comment = [GHRepoComment commentWithRepo:self.repository
										andDictionary:[self.payload valueForKey:@"comment"]];
		if (!self.commits) {
			GHCommit *commit = [GHCommit commitWithRepo:self.repository
												 andSha:[self.payload valueForKeyPath:@"comment.commit_id"]];
			self.commits = [NSArray arrayWithObject:commit];
		}
	}

	// Wiki
	NSArray *pages = [self.payload valueForKey:@"pages"];
	if (pages) {
		self.pages = [NSMutableArray arrayWithCapacity:pages.count];
		for (NSDictionary *pageDict in pages) {
			[self.pages addObject:pageDict];
		}
	}
}

- (NSString *)title {
	if (_title) return _title;

	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		NSString *commitId = [self shortenSha:[self.payload valueForKeyPath:@"comment.commit_id"]];
		self.title = [NSString stringWithFormat:@"%@ commented on %@ at %@", self.user.login, commitId, self.repoName];
	}

	else if ([self.eventType isEqualToString:@"CreateEvent"]) {
		NSString *ref = [self.payload valueForKey:@"ref"];
		NSString *refType = [self.payload valueForKey:@"ref_type"];
		if ([refType isEqualToString:@"repository"]) { // created repository
			self.title = [NSString stringWithFormat:@"%@ created %@ %@", self.user.login, refType, self.repository.name];
		} else { // created branch or tag
			self.title = [NSString stringWithFormat:@"%@ created %@ %@ at %@", self.user.login, refType, ref, self.repoName];
		}
	}

	else if ([self.eventType isEqualToString:@"DeleteEvent"]) {
		NSString *ref = [self.payload valueForKey:@"ref"];
		NSString *refType = [self.payload valueForKey:@"ref_type"];
		self.title = [NSString stringWithFormat:@"%@ deleted %@ %@ at %@", self.user.login, refType, ref, self.repoName];
	}

	else if ([self.eventType isEqualToString:@"DownloadEvent"]) {
		NSString *name = [self.payload valueForKeyPath:@"download.name"];
		self.title = [NSString stringWithFormat:@"%@ created download %@ at %@", self.user.login, name, self.repository.name];
	}

	else if ([self.eventType isEqualToString:@"FollowEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ started following %@", self.user.login, self.otherUser.login];
	}

	else if ([self.eventType isEqualToString:@"ForkEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ forked %@ to %@", self.user.login, self.repository.repoId, self.otherRepository.repoId];
	}

	else if ([self.eventType isEqualToString:@"ForkApplyEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ applied a patch to %@", self.user.login, self.repository.repoId];
	}

	else if ([self.eventType isEqualToString:@"GistEvent"]) {
		NSString *action = [self.payload valueForKey:@"action"];
		if ([action isEqualToString:@"create"]) {
			action = @"created";
		} else if ([action isEqualToString:@"update"]) {
			action = @"updated";
		}
		self.title = [NSString stringWithFormat:@"%@ %@ gist %@", self.user.login, action, self.gist.gistId];
	}

	else if ([self.eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = [self.pages objectAtIndex:0];
		NSString *action = [firstPage valueForKey:@"action"];
		NSString *pageName = [firstPage valueForKey:@"page_name"];
		self.title = [NSString stringWithFormat:@"%@ %@ \"%@\" in the %@ wiki", self.user.login, action, pageName, self.repository.repoId];
	}

	else if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		NSString *parentType = self.pullRequest ? @"pull request" : @"issue";
		NSUInteger num = [(GHIssue *)issueCommentParent num];
		self.title = [NSString stringWithFormat:@"%@ commented on %@ %@#%d", self.user.login, parentType, self.repoName, num];
	}

	else if ([self.eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = [self.payload valueForKey:@"action"];
		self.title = [NSString stringWithFormat:@"%@ %@ issue %@#%d", self.user.login, action, self.repoName, self.issue.num];
	}

	else if ([self.eventType isEqualToString:@"MemberEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ added %@ to %@", self.user.login, self.otherUser.login, self.repoName];
	}

	else if ([self.eventType isEqualToString:@"PublicEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ open sourced %@", self.user.login, self.repository.repoId];
	}

	else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = [self.payload valueForKey:@"action"];
		if ([action isEqualToString:@"closed"]) action = @"merged";
		self.title = [NSString stringWithFormat:@"%@ %@ pull request %@#%d", self.user.login, action, self.repoName, self.pullRequest.num];
	}

	else if ([self.eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ commented on pull request %@#%d", self.user.login, self.repoName, self.pullRequest.num];
	}

	else if ([self.eventType isEqualToString:@"PushEvent"]) {
		NSString *ref = [self shortenRef:[self.payload valueForKey:@"ref"]];
		self.title = [NSString stringWithFormat:@"%@ pushed to %@ at %@", self.user.login, ref, self.repoName];
	}

	else if ([self.eventType isEqualToString:@"TeamAddEvent"]) {
		NSString *teamName = [self.payload valueForKeyPath:@"team.name"];
		// for older events the team may not be set, so leave out to which team the user was added
		NSString *teamInfo = teamName ? [NSString stringWithFormat:@" to %@", teamName] : @"";
		self.title = [NSString stringWithFormat:@"%@ added %@%@", self.user.login, self.otherUser.login, teamInfo];
	}

	else if ([self.eventType isEqualToString:@"WatchEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ starred %@", self.user.login, self.repoName];
	}

	return _title;
}

- (NSString *)content {
	if (_content) return _content;

	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		self.content = [self.payload valueForKeyPath:@"comment.body"];
	}

	else if ([self.eventType isEqualToString:@"CreateEvent"]) {
		NSString *refType = [self.payload valueForKey:@"ref_type"];
		self.content = [refType isEqualToString:@"repository"] ? self.repository.descriptionText : @"";
	}

	else if ([self.eventType isEqualToString:@"ForkEvent"]) {
		self.content = self.otherRepository.descriptionText;
	}

	else if ([self.eventType isEqualToString:@"GistEvent"]) {
		self.content = self.gist.descriptionText;
	}

	else if ([self.eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = [self.pages objectAtIndex:0];
		self.content = [firstPage valueForKey:@"summary" defaultsTo:@""];
	}

	else if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		self.content = [self.payload valueForKeyPath:@"comment.body"];
	}

	else if ([self.eventType isEqualToString:@"IssuesEvent"]) {
		self.content = self.issue.title;
	}

	else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
		self.content = self.pullRequest.title;
	}

	else if ([self.eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self.content = [self.payload valueForKeyPath:@"comment.body"];
	}

	else if ([self.eventType isEqualToString:@"PushEvent"]) {
		NSMutableArray *messages = [NSMutableArray arrayWithCapacity:self.commits.count];
		for (GHCommit *commit in self.commits) {
			NSString *formatted = [NSString stringWithFormat:@"• %@", [self shortenMessage:commit.message]];
			[messages addObject:formatted];
		}
		self.content = [messages componentsJoinedByString:@"\n"];
	}

	return _content;
}

- (NSString *)shortenMessage:(NSString *)longMessage {
	NSArray *comps = [longMessage componentsSeparatedByString:@"\n"];
	return [comps objectAtIndex:0];
}

- (NSString *)shortenSha:(NSString *)longSha {
	return [longSha substringToIndex:6];
}

- (NSString *)shortenRef:(NSString *)longRef {
	return [longRef lastPathComponent];
}

@end
