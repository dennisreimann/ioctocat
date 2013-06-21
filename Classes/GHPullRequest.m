#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHCommits.h"
#import "GHBranch.h"
#import "GHFiles.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "GHFMarkdown.h"
#import "NSURL_IOCExtensions.h"
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHPullRequest ()
@property(nonatomic,assign)BOOL isMerged;
@property(nonatomic,assign)BOOL isMergeable;
@property(nonatomic,strong)NSMutableAttributedString *attributedBody;
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
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@/%@/pull/%d", self.repository.owner, self.repository.name, self.number];
    }
    return _htmlURL;
}

- (NSString *)repoIdWithIssueNumber {
	return [NSString stringWithFormat:@"%@#%d", self.repository.repoId, self.number];
}

- (NSMutableAttributedString *)attributedBody {
    if (!_attributedBody) {
        NSString *text = self.body;
        text = [text emojizedString];
        _attributedBody = [text ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.repository.repoId];
    }
    return _attributedBody;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict ioc_stringForKeyPath:@"user.login"];
	self.user = [iOctocat.sharedInstance userWithLogin:login];
	self.createdAt = [dict ioc_dateForKey:@"created_at"];
	self.updatedAt = [dict ioc_dateForKey:@"updated_at"];
	self.mergedAt = [dict ioc_dateForKey:@"merged_at"];
	self.closedAt = [dict ioc_dateForKey:@"closed_at"];
	self.title = [dict ioc_stringForKey:@"title"];
	self.body = [dict ioc_stringForKey:@"body"];
	self.state = [dict ioc_stringForKey:@"state"];
	self.labels = [dict ioc_arrayForKey:@"labels"];
	self.number = [dict ioc_integerForKey:@"number"];
	self.htmlURL = [dict ioc_URLForKey:@"html_url"];
	self.isMerged = [dict ioc_boolForKey:@"merged"];
	self.isMergeable = [dict ioc_boolForKey:@"mergeable"];
    self.mergeableState = [dict ioc_stringOrNilForKey:@"mergeable_state"];
	if (!self.repository) {
		NSString *owner = [dict ioc_stringForKeyPath:@"repository.owner.login"];
		NSString *name = [dict ioc_stringForKeyPath:@"repository.name"];
		if (![owner ioc_isEmpty] && ![name ioc_isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
	NSString *headOwner = [dict ioc_stringForKeyPath:@"head.repo.owner.login"];
	NSString *headName = [dict ioc_stringForKeyPath:@"head.repo.name"];
	NSString *headRef = [dict ioc_stringForKeyPath:@"head.ref"];
	GHRepository *headRepo = [[GHRepository alloc] initWithOwner:headOwner andName:headName];
	self.head = [[GHBranch alloc] initWithRepository:headRepo andName:headRef];
	[self.head setValues:[dict ioc_dictForKeyPath:@"head"]];
}

#pragma mark State toggling

- (void)mergePullRequest:(NSString *)commitMessage start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kPullRequestMergeFormat, self.repository.owner, self.repository.name, self.number];
	NSDictionary *params = @{@"commit_message": commitMessage};
	[self saveWithParams:params path:path method:kRequestMethodPut start:start success:^(GHResource *instance, id data) {
		self.isMerged = [data ioc_boolForKey:@"merged"];
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