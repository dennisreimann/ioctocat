#import "GHPullRequest.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHPullRequest

+ (id)pullRequestWithRepository:(GHRepository *)theRepository {
	return [[self.class alloc] initWithRepository:theRepository];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.comments = [GHIssueComments commentsWithParent:self];
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

- (void)setValues:(id)theDict {
	NSString *login = [theDict valueForKeyPath:@"user.login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.created = [iOctocat parseDate:[theDict objectForKey:@"created_at"]];
	self.updated = [iOctocat parseDate:[theDict objectForKey:@"updated_at"]];
	self.closed = [iOctocat parseDate:[theDict objectForKey:@"closed_at"]];
	self.title = [theDict objectForKey:@"title"];
	self.body = [theDict objectForKey:@"body"];
	self.state = [theDict objectForKey:@"state"];
	self.labels = [theDict objectForKey:@"labels"];
	self.votes = [[theDict objectForKey:@"votes"] integerValue];
	self.num = [[theDict objectForKey:@"number"] integerValue];
	self.htmlURL = [NSURL URLWithString:[theDict objectForKey:@"html_url"]];
	if (!self.repository) {
		NSString *owner = [theDict valueForKeyPath:@"repository.owner.login" defaultsTo:nil];
		NSString *name = [theDict valueForKeyPath:@"repository.name" defaultsTo:nil];
		if (owner && name) {
			self.repository = [GHRepository repositoryWithOwner:owner andName:name];
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
		method = @"POST";
	} else {
		path = [NSString stringWithFormat:kIssueEditFormat, self.repository.owner, self.repository.name, self.num];
		method = @"PATCH";
	}
	NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:self.title, @"title", self.body, @"body", self.state, @"state", nil];
	[self saveValues:values withPath:path andMethod:method useResult:^(id theResponse) {
		[self setValues:theResponse];
	}];
}

@end