#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHCommits.h"
#import "GHFiles.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHPullRequest ()
@property(nonatomic,assign)BOOL isMerged;
@property(nonatomic,assign)BOOL isMergable;
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
	self.created = [iOctocat parseDate:[dict safeStringForKey:@"created_at"]];
	self.updated = [iOctocat parseDate:[dict safeStringForKey:@"updated_at"]];
	self.merged = [iOctocat parseDate:[dict safeStringForKey:@"merged_at"]];
	self.closed = [iOctocat parseDate:[dict safeStringForKey:@"closed_at"]];
	self.title = [dict safeStringForKey:@"title"];
	self.body = [dict safeStringForKey:@"body"];
	self.state = [dict safeStringForKey:@"state"];
	self.labels = [dict safeArrayForKey:@"labels"];
	self.num = [dict safeIntegerForKey:@"number"];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	self.isMerged = [dict safeBoolForKey:@"merged"];
	self.isMergable = [dict safeBoolForKey:@"mergable"];
	if (!self.repository) {
		NSString *owner = [dict safeStringForKeyPath:@"repository.owner.login"];
		NSString *name = [dict safeStringForKeyPath:@"repository.name"];
		if (![owner isEmpty] && ![name isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
}

#pragma mark State toggling

- (void)mergePullRequest {
	if (self.isMergable) {
		// TODO: Implement
	}
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