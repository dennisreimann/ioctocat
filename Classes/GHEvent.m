#import "GHEvent.h"
#import "GHRepository.h"
#import "GHCommits.h"
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

- (id)initWithDict:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		self.read = NO;
		[self setValues:dict];
	}
	return self;
}

- (NSString *)extendedEventType {
	NSString *action = [self.payload safeStringForKey:@"action"];
	if ([self.eventType isEqualToString:@"IssuesEvent"]) {
		return [action isEqualToString:@"closed"] ? @"IssuesClosedEvent" : @"IssuesOpenedEvent";
	} else if ([self.eventType isEqualToString:@"PullRequestEvent"]) {
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
	self.eventID = [dict safeStringForKey:@"id"];
	self.eventType = [dict safeStringForKey:@"type"];
	self.payload = [dict safeDictForKey:@"payload"];
	self.date = [dict safeDateForKey:@"created_at"];

	NSString *actorLogin = [dict safeStringForKeyPath:@"actor.login"];
	NSString *orgLogin = [dict safeStringForKeyPath:@"org.login"];

	// User
	if (![actorLogin isEmpty]) {
		self.user = [[iOctocat sharedInstance] userWithLogin:actorLogin];
		if (!self.user.gravatarURL) {
			self.user.gravatarURL = [dict safeURLForKeyPath:@"actor.avatar_url"];;
		}
	}

	// Organization
	if (![orgLogin isEmpty]) {
		self.organization = [[iOctocat sharedInstance] organizationWithLogin:orgLogin];
		if (!self.organization.gravatarURL) {
			self.organization.gravatarURL = [dict safeURLForKeyPath:@"org.avatar_url"];
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
		otherUserLogin = [[dict safeStringForKeyPath:@"repo.name"] componentsSeparatedByString:@"/"][0];
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
	self.repoName = [dict safeStringForKeyPath:@"repo.name"];
	NSArray *repoParts = [self.repoName componentsSeparatedByString:@"/"];
	if (repoParts.count == 2) {
		NSString *rOwner = repoParts[0];
		NSString *rName = repoParts[1];
		if (!!rOwner && !!rName && ![rOwner isEmpty] && ![rName isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:rOwner andName:rName];
			self.repository.descriptionText = [self.payload safeStringForKey:@"description"];
		}
	}

	// Other Repository
	NSString *otherRepoName = [self.payload safeStringForKeyPath:@"forkee.name"];
	NSString *otherRepoOwner = [self.payload safeStringForKeyPath:@"forkee.owner.login"];
	if (![otherRepoOwner isEmpty] && ![otherRepoName isEmpty]) {
		self.otherRepository = [[GHRepository alloc] initWithOwner:otherRepoOwner andName:otherRepoName];
		self.otherRepository.descriptionText = [self.payload safeStringForKeyPath:@"forkee.description"];
	}

	// Issue
	NSDictionary *issueDict = [self.payload safeDictForKey:@"issue"];
	NSInteger issueNumber = [issueDict safeIntegerForKey:@"number"];
	if (issueDict && issueNumber) {
		self.issue = [[GHIssue alloc] initWithRepository:self.repository];
		self.issue.num = issueNumber;
		[self.issue setValues:issueDict];
	}

	// Pull Request
	NSDictionary *pullPayload = [self.payload safeDictForKey:@"pull_request"];
	if (!pullPayload) pullPayload = [self.payload safeDictForKeyPath:@"issue.pull_request"];
	// this check is somehow hacky, but the API provides empty pull_request
	// urls in case there is no pull request associated with an issue.
	// an IssueCommentEvent with an associated pull request has the urls
	// set, but it does not contain the pull request number in the payload
	// for issue.pull_request, so we have to use the issue number then
	if (pullPayload && [pullPayload safeURLForKey:@"html_url"]) {
		NSInteger pullNumber = [pullPayload safeIntegerForKey:@"number"];
		if (!pullNumber) pullNumber = self.issue.num;
		self.pullRequest = [[GHPullRequest alloc] initWithRepository:self.repository];
		self.pullRequest.num = pullNumber;
		self.pullRequest.title = [self.payload safeStringForKeyPath:@"pull_request.title"];
	}

	// Issue Comment (which might also be a pull request comment)
	if ([self.eventType isEqualToString:@"IssueCommentEvent"]) {
		id issueCommentParent = self.pullRequest ? self.pullRequest : self.issue;
		self.comment = [[GHIssueComment alloc] initWithParent:issueCommentParent];
		[self.comment setValues:[self.payload safeDictForKey:@"comment"]];
	}

	// Gist
	NSString *gistId = [self.payload valueForKeyPath:@"gist.id"];
	if (gistId) {
		self.gist = [[GHGist alloc] initWithId:gistId];
		[self.gist setValues:self.payload[@"gist"]];
	}

	// Commits
	NSArray *commits = [self.payload safeArrayForKey:@"commits"];
	if (commits) {
		self.commits = [[GHCommits alloc] initWithRepository:self.repository];
		[self.commits setValues:commits];
		[self.commits markAsLoaded];
		// set the author, because this isn't provided in the api json
		for (GHCommit *commit in self.commits.items) {
			commit.author = self.user;
		}
	}

	// Commit Comment
	if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
		self.comment = [[GHRepoComment alloc] initWithRepo:self.repository];
		[self.comment setValues:[self.payload safeDictForKey:@"comment"]];
		if (!self.commits) {
			NSString *sha = [self.payload safeStringForKeyPath:@"comment.commit_id"];
			self.commits = [[GHCommits alloc] initWithRepository:self.repository];
			[self.commits setValues:@[@{@"sha": sha}]];
			[self.commits markAsLoaded];
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

	@try {
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

	}

	@catch (NSException *e) {
		self.title = @"";

	}

	return _title;
}

- (NSString *)content {
	if (_content) return _content;

	@try {
		if ([self.eventType isEqualToString:@"CommitCommentEvent"]) {
			self.content = [self.payload safeStringForKeyPath:@"comment.body"];
		}

		else if ([self.eventType isEqualToString:@"CreateEvent"]) {
			NSString *refType = [self.payload safeStringForKey:@"ref_type"];
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
			self.content = [firstPage safeStringForKey:@"summary"];
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
			self.content = [self.payload safeStringForKeyPath:@"comment.body"];
		}

		else if ([self.eventType isEqualToString:@"PushEvent"]) {
			NSMutableArray *messages = [NSMutableArray arrayWithCapacity:self.commits.count];
			for (GHCommit *commit in self.commits.items) {
				NSString *formatted = [NSString stringWithFormat:@"• %@", [self shortenMessage:commit.message]];
				[messages addObject:formatted];
			}
			self.content = [messages componentsJoinedByString:@"\n"];
		}
	}

	@catch (NSException *e) {
		self.content = @"";
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
