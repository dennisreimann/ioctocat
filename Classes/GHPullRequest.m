#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHCommits.h"
#import "GHBranch.h"
#import "GHFiles.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHPullRequest ()
@property(nonatomic,assign)BOOL isMerged;
@property(nonatomic,assign)BOOL isMergeable;
@end


@implementation GHPullRequest

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.comments = [[GHIssueComments alloc] initWithParent:self];
		self.commits = [[GHCommits alloc] initWithPullRequest:self];
		self.files = [[GHFiles alloc] initWithPullRequest:self];
		self.state = kIssueStateOpen;
	}
	return self;
}

- (BOOL)isNew {
	return !self.num ? YES : NO;
}

- (BOOL)isOpen {
	return [self.state isEqualToString:kIssueStateOpen];
}

- (BOOL)isClosed {
	return [self.state isEqualToString:kIssueStateClosed];
}

// Dynamic resourcePath, because it depends on the
// num which isn't always available in advance
- (NSString *)resourcePath {
	return [NSString stringWithFormat:kPullRequestFormat, self.repository.owner, self.repository.name, self.num];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKeyPath:@"user.login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.created = [dict safeDateForKey:@"created_at"];
	self.updated = [dict safeDateForKey:@"updated_at"];
	self.merged = [dict safeDateForKey:@"merged_at"];
	self.closed = [dict safeDateForKey:@"closed_at"];
	self.title = [dict safeStringForKey:@"title"];
	self.body = [dict safeStringForKey:@"body"];
	self.state = [dict safeStringForKey:@"state"];
	self.labels = [dict safeArrayForKey:@"labels"];
	self.num = [dict safeIntegerForKey:@"number"];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	self.isMerged = [dict safeBoolForKey:@"merged"];
	self.isMergeable = [dict safeBoolForKey:@"mergeable"];
	if (!self.repository) {
		NSString *owner = [dict safeStringForKeyPath:@"repository.owner.login"];
		NSString *name = [dict safeStringForKeyPath:@"repository.name"];
		if (![owner isEmpty] && ![name isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
	NSString *headOwner = [dict safeStringForKeyPath:@"head.repo.owner.login"];
	NSString *headName = [dict safeStringForKeyPath:@"head.repo.name"];
	NSString *headRef = [dict safeStringForKeyPath:@"head.ref"];
	GHRepository *headRepo = [[GHRepository alloc] initWithOwner:headOwner andName:headName];
	self.head = [[GHBranch alloc] initWithRepository:headRepo andName:headRef];
	[self.head setValues:[dict safeDictForKeyPath:@"head"]];
}

#pragma mark State toggling

- (void)mergePullRequest:(NSString *)commitMessage {
	if (self.isMergeable) {
		NSString *path = [NSString stringWithFormat:kPullRequestMergeFormat, self.repository.owner, self.repository.name, self.num];
		NSDictionary *values = @{@"commit_message": commitMessage};
		[self saveValues:values withPath:path andMethod:kRequestMethodPut useResult:^(id response) {
			self.isMerged = [response safeBoolForKey:@"merged"];
			// set values manually that are not part of the response
			if (self.isMerged) {
				self.state = kIssueStateClosed;
				self.merged = self.closed = self.updated = [NSDate date];
				self.isMergeable = NO;
			} else {
				self.state = kIssueStateOpen;
				self.merged = self.closed = nil;
			}
		}];
	}
}

- (void)closePullRequest {
	self.state = kIssueStateClosed;
	[self saveData];
}

- (void)reopenPullRequest {
	self.state = kIssueStateOpen;
	[self saveData];
}

#pragma mark Saving

- (void)saveData {
	NSString *path;
	NSString *method;
	if (self.isNew) {
		path = [NSString stringWithFormat:kIssueOpenFormat, self.repository.owner, self.repository.name];
		method = kRequestMethodPost;
	} else {
		path = [NSString stringWithFormat:kIssueEditFormat, self.repository.owner, self.repository.name, self.num];
		method = kRequestMethodPatch;
	}
	NSDictionary *values = @{@"title": self.title, @"body": self.body, @"state": self.state};
	[self saveValues:values withPath:path andMethod:method useResult:^(id response) {
		[self setValues:response];
	}];
}

@end