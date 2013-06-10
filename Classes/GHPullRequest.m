#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHCommits.h"
#import "GHBranch.h"
#import "GHFiles.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
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
		self.state = kIssueStateOpen;
	}
	return self;
}

- (BOOL)isNew {
	return !self.number ? YES : NO;
}

- (BOOL)isOpen {
	return [self.state isEqualToString:kIssueStateOpen];
}

- (GHIssueComments *)comments {
    if (!_comments) {
        _comments = [[GHIssueComments alloc] initWithParent:self];
    }
    return _comments;
}

- (GHCommits *)commits {
    if (!_commits) {
        _commits = [[GHCommits alloc] initWithPullRequest:self];
    }
    return _commits;
}

- (GHFiles *)files {
    if (!_files) {
        _files = [[GHFiles alloc] initWithPullRequest:self];
    }
    return _files;
}

- (NSString *)resourcePath {
	if (self.isNew) {
		return [NSString stringWithFormat:kPullRequestOpenFormat, self.repository.owner, self.repository.name];
	} else {
        return [NSString stringWithFormat:kPullRequestFormat, self.repository.owner, self.repository.name, self.number];
	}
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL URLWithFormat:@"/%@/%@/pull/%d", self.repository.owner, self.repository.name, self.number];
    }
    return _htmlURL;
}

- (NSString *)repoIdWithIssueNumber {
	return [NSString stringWithFormat:@"%@#%d", self.repository.repoId, self.number];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKeyPath:@"user.login"];
	self.user = [iOctocat.sharedInstance userWithLogin:login];
	self.createdAt = [dict safeDateForKey:@"created_at"];
	self.updatedAt = [dict safeDateForKey:@"updated_at"];
	self.mergedAt = [dict safeDateForKey:@"merged_at"];
	self.closedAt = [dict safeDateForKey:@"closed_at"];
	self.title = [dict safeStringForKey:@"title"];
	self.body = [dict safeStringForKey:@"body"];
	self.state = [dict safeStringForKey:@"state"];
	self.labels = [dict safeArrayForKey:@"labels"];
	self.number = [dict safeIntegerForKey:@"number"];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	self.isMerged = [dict safeBoolForKey:@"merged"];
	self.isMergeable = [dict safeBoolForKey:@"mergeable"];
    self.mergeableState = [dict safeStringOrNilForKey:@"mergeable_state"];
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

- (void)mergePullRequest:(NSString *)commitMessage start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kPullRequestMergeFormat, self.repository.owner, self.repository.name, self.number];
	NSDictionary *params = @{@"commit_message": commitMessage};
	[self saveWithParams:params path:path method:kRequestMethodPut start:start success:^(GHResource *instance, id data) {
		self.isMerged = [data safeBoolForKey:@"merged"];
		// set values manually that are not part of the response
		if (self.isMerged) {
			self.state = kIssueStateClosed;
			self.mergedAt = self.closedAt = self.updatedAt = [NSDate date];
			self.isMergeable = NO;
		} else {
			self.state = kIssueStateOpen;
			self.mergedAt = self.closedAt = nil;
		}
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end