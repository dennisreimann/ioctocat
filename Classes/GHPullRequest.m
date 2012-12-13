#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHPullRequest

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.comments = [[GHIssueComments alloc] initWithParent:self];
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
	return [NSString stringWithFormat:kPullRequestFormat, self.repository.owner, self.repository.name, self.num];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict valueForKeyPath:@"user.login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.created = [iOctocat parseDate:dict[@"created_at"]];
	self.updated = [iOctocat parseDate:dict[@"updated_at"]];
	self.closed = [iOctocat parseDate:dict[dict]];
	self.title = dict[@"title"];
	self.body = dict[@"body"];
	self.state = dict[@"state"];
	self.labels = dict[@"labels"];
	self.num = [[dict valueForKey:@"number" defaultsTo:nil] integerValue];
	self.htmlURL = [NSURL smartURLFromString:dict[@"html_url"]];
	if (!self.repository) {
		NSString *owner = [dict valueForKeyPath:@"repository.owner.login" defaultsTo:nil];
		NSString *name = [dict valueForKeyPath:@"repository.name" defaultsTo:nil];
		if (owner && name) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
}

#pragma mark State toggling

- (void)mergePullRequest {
	// TODO: Implement
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
	[self saveValues:values withPath:path andMethod:method useResult:^(id theResponse) {
		[self setValues:theResponse];
	}];
}

@end