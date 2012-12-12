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


@implementation GHEvent

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
		NSString *action = self.payload[@"action"];
		return [action isEqualToString:@"closed"] ? @"IssuesClosedEvent" : @"IssuesOpenedEvent";
	} else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = self.payload[@"action"];
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

- (void)setValues:(id)dict {
	self.eventID = dict[@"id"];
	self.eventType = dict[@"type"];
	self.date = [iOctocat parseDate:dict[@"created_at"]];
	self.payload = dict[@"payload"];

	NSString *actorLogin = [dict valueForKeyPath:@"actor.login"];
	NSString *orgLogin = [dict valueForKeyPath:@"org.login"];

	// User
	if (![actorLogin isEmpty]) {
		self.user = [[iOctocat sharedInstance] userWithLogin:actorLogin];
		NSString *avatarURL = [dict valueForKeyPath:@"actor.avatar_url"];
		if (!self.user.gravatarURL && ![avatarURL isEmpty]) {
			self.user.gravatarURL = [NSURL smartURLFromString:avatarURL];
		}
	}

	// Organization
	if (![orgLogin isEmpty]) {
		self.organization = [[iOctocat sharedInstance] organizationWithLogin:orgLogin];
		NSString *avatarURL = [dict valueForKeyPath:@"org.avatar_url"];
		if (!self.organization.gravatarURL && ![avatarURL isEmpty]) {
			self.organization.gravatarURL = [NSURL smartURLFromString:avatarURL];
		}
	}

	// Other user
	NSString *otherUserLogin = nil;
	NSString *otherUserAvatarURL = nil;
	NSDictionary *otherUserDict = self.payload[@"target"];
	if (!otherUserDict) otherUserDict = self.payload[@"member"];
	if (!otherUserDict) otherUserDict = self.payload[@"user"];
	if (!otherUserDict && !self.organization && [self.eventType isEqualToString:@"WatchEvent"]) {
		// use repo owner as fallback
		otherUserLogin = [[dict valueForKeyPath:@"repo.name"] componentsSeparatedByString:@"/"][0];
	} else if (otherUserDict) {
		otherUserLogin = otherUserDict[@"login"];
		otherUserAvatarURL = otherUserDict[@"avatar_url"];
	}
	if (![otherUserLogin isEmpty]) {
		self.otherUser = [[iOctocat sharedInstance] userWithLogin:otherUserLogin];
		if (!self.otherUser.gravatarURL && ![otherUserAvatarURL isEmpty]) {
			self.otherUser.gravatarURL = [NSURL smartURLFromString:otherUserAvatarURL];
		}
	}

	// Repository
	self.repoName = [dict valueForKeyPath:@"repo.name"];
	NSArray *rParts = [self.repoName componentsSeparatedByString:@"/"];
	NSString *rOwner = rParts[0];
	NSString *rName = rParts[1];
	if (!!rOwner && !!rName && ![rOwner isEmpty] && ![rName isEmpty]) {
		self.repository = [[GHRepository alloc] initWithOwner:rOwner andName:rName];
		self.repository.descriptionText = self.payload[@"description"];
	}

	// Other Repository
	self.otherRepoName = [self.payload valueForKeyPath:@"forkee.full_name"];
	rParts = [self.otherRepoName componentsSeparatedByString:@"/"];
	rOwner = rParts[0];
	rName = rParts[1];
	if (!!rOwner && !!rName && ![rOwner isEmpty] && ![rName isEmpty]) {
		self.otherRepository = [[GHRepository alloc] initWithOwner:rOwner andName:rName];
		self.otherRepository.descriptionText = [self.payload valueForKeyPath:@"forkee.description"];
	}

	// Issue
	NSInteger issueNumber = [[self.payload valueForKeyPath:@"issue.number" defaultsTo:nil] integerValue];
	if (issueNumber > 0) {
		self.issue = [[GHIssue alloc] initWithRepository:self.repository];
		self.issue.num = issueNumber;
		[self.issue setValues:self.payload[@"issue"]];
	}

	// Pull Request
	NSDictionary *pullPayload = self.payload[@"pull_request"];
	if (!pullPayload) pullPayload = [self.payload valueForKeyPath:@"issue.pull_request"];
	// this check is somehow hacky, but the API provides empty pull_request
	// urls in case there is no pull request associated with an issue
	if (pullPayload && ![[pullPayload valueForKey:@"html_url" defaultsTo:@""] isEmpty]) {
		NSInteger pullNumber = [[pullPayload valueForKey:@"number" defaultsTo:nil] integerValue];
		if (!pullNumber) pullNumber = self.issue.num;
		self.pullRequest = [[GHPullRequest alloc] initWithRepository:self.repository];
		self.pullRequest.num = pullNumber;
		self.pullRequest.title = [self.payload valueForKeyPath:@"pull_request.title"];
	}

	// Issue Comment (which might also be a pull request comment)
	if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		self.comment = [[GHIssueComment alloc] initWithParent:issueCommentParent
												andDictionary:self.payload[@"comment"]];
	}

	// Gist
	NSString *gistId = [self.payload valueForKeyPath:@"gist.id"];
	if (gistId) {
		self.gist = [[GHGist alloc] initWithId:gistId];
		[self.gist setValues:self.payload[@"gist"]];
	}

	// Commits
	NSArray *commits = self.payload[@"commits"];
	if (commits) {
		self.commits = [NSMutableArray arrayWithCapacity:commits.count];
		for (NSDictionary *dict in commits) {
			GHCommit *commit = [[GHCommit alloc] initWithRepository:self.repository
														andCommitID:dict[@"sha"]];
			commit.author = self.user;
			commit.message = [dict valueForKey:@"message" defaultsTo:@""];
			[self.commits addObject:commit];
		}
	}

	// Commit Comment
	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		self.comment = [[GHRepoComment alloc] initWithRepo:self.repository
											 andDictionary:self.payload[@"comment"]];
		if (!self.commits) {
			GHCommit *commit = [[GHCommit alloc] initWithRepository:self.repository
												 andCommitID:[self.payload valueForKeyPath:@"comment.commit_id"]];
			self.commits = [@[commit] mutableCopy];
		}
	}

	// Wiki
	NSArray *pages = self.payload[@"pages"];
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
		NSString *ref = self.payload[@"ref"];
		NSString *refType = self.payload[@"ref_type"];
		if ([refType isEqualToString:@"repository"]) { // created repository
			self.title = [NSString stringWithFormat:@"%@ created %@ %@", self.user.login, refType, self.repository.name];
		} else { // created branch or tag
			self.title = [NSString stringWithFormat:@"%@ created %@ %@ at %@", self.user.login, refType, ref, self.repoName];
		}
	}

	else if ([self.eventType isEqualToString:@"DeleteEvent"]) {
		NSString *ref = self.payload[@"ref"];
		NSString *refType = self.payload[@"ref_type"];
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
		NSString *action = self.payload[@"action"];
		if ([action isEqualToString:@"create"]) {
			action = @"created";
		} else if ([action isEqualToString:@"update"]) {
			action = @"updated";
		}
		self.title = [NSString stringWithFormat:@"%@ %@ gist %@", self.user.login, action, self.gist.gistId];
	}

	else if ([self.eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = (self.pages)[0];
		NSString *action = firstPage[@"action"];
		NSString *pageName = firstPage[@"page_name"];
		self.title = [NSString stringWithFormat:@"%@ %@ \"%@\" in the %@ wiki", self.user.login, action, pageName, self.repository.repoId];
	}

	else if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		NSString *parentType = self.pullRequest ? @"pull request" : @"issue";
		NSUInteger num = [(GHIssue *)issueCommentParent num];
		self.title = [NSString stringWithFormat:@"%@ commented on %@ %@#%d", self.user.login, parentType, self.repoName, num];
	}

	else if ([self.eventType isEqualToString:@"IssuesEvent"]) {
		NSString *action = self.payload[@"action"];
		self.title = [NSString stringWithFormat:@"%@ %@ issue %@#%d", self.user.login, action, self.repoName, self.issue.num];
	}

	else if ([self.eventType isEqualToString:@"MemberEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ added %@ to %@", self.user.login, self.otherUser.login, self.repoName];
	}

	else if ([self.eventType isEqualToString:@"PublicEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ open sourced %@", self.user.login, self.repository.repoId];
	}

	else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
		NSString *action = self.payload[@"action"];
		if ([action isEqualToString:@"closed"]) action = @"merged";
		self.title = [NSString stringWithFormat:@"%@ %@ pull request %@#%d", self.user.login, action, self.repoName, self.pullRequest.num];
	}

	else if ([self.eventType isEqualToString:@"PullRequestReviewCommentEvent"]) {
		self.title = [NSString stringWithFormat:@"%@ commented on pull request %@#%d", self.user.login, self.repoName, self.pullRequest.num];
	}

	else if ([self.eventType isEqualToString:@"PushEvent"]) {
		NSString *ref = [self shortenRef:self.payload[@"ref"]];
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
		NSString *refType = self.payload[@"ref_type"];
		self.content = [refType isEqualToString:@"repository"] ? self.repository.descriptionText : @"";
	}

	else if ([self.eventType isEqualToString:@"ForkEvent"]) {
		self.content = self.otherRepository.descriptionText;
	}

	else if ([self.eventType isEqualToString:@"GistEvent"]) {
		self.content = self.gist.descriptionText;
	}

	else if ([self.eventType isEqualToString:@"GollumEvent"]) {
		NSDictionary *firstPage = (self.pages)[0];
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
	return comps[0];
}

- (NSString *)shortenSha:(NSString *)longSha {
	return [longSha substringToIndex:6];
}

- (NSString *)shortenRef:(NSString *)longRef {
	return [longRef lastPathComponent];
}

@end
