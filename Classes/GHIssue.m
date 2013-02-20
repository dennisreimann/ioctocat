#import "GHIssue.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHIssue

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.comments = [[GHIssueComments alloc] initWithParent:self];
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

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// num which isn't always available in advance
	return [NSString stringWithFormat:kIssueFormat, self.repository.owner, self.repository.name, self.num];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKeyPath:@"user.login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.created = [dict safeDateForKey:@"created_at"];
	self.updated = [dict safeDateForKey:@"updated_at"];
	self.closed = [dict safeDateForKey:@"closed_at"];
	self.title = [dict safeStringForKey:@"title"];
	self.body = [dict safeStringForKey:@"body"];
	self.state = [dict safeStringForKey:@"state"];
	self.labels = [dict safeArrayForKey:@"labels"];
	self.num = [dict safeIntegerForKey:@"number"];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	if (!self.repository) {
		NSString *owner = [dict safeStringForKeyPath:@"repository.owner.login"];
		NSString *name = [dict safeStringForKeyPath:@"repository.name"];
		if (![owner isEmpty] && ![name isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
}

#pragma mark Saving

- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = nil;
	NSString *method = nil;
	if (self.isNew) {
		path = [NSString stringWithFormat:kIssueOpenFormat, self.repository.owner, self.repository.name];
		method = kRequestMethodPost;
	} else {
		path = [NSString stringWithFormat:kIssueEditFormat, self.repository.owner, self.repository.name, self.num];
		method = kRequestMethodPatch;
	}
	[self saveWithParams:params path:path method:method start:nil success:^(GHResource *instance, id data) {
		[self setValues:data];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end