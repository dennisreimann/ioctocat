#import "GHIssue.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHIssue

@synthesize user;
@synthesize comments;
@synthesize title;
@synthesize body;
@synthesize state;
@synthesize labels;
@synthesize votes;
@synthesize created;
@synthesize updated;
@synthesize closed;
@synthesize num;
@synthesize repository;
@synthesize htmlURL;

+ (id)issueWithRepository:(GHRepository *)theRepository {
    return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	[super init];
	self.repository = theRepository;
	self.comments = [GHIssueComments commentsWithIssue:self];
	return self;
}

- (void)dealloc {
    [user release], user = nil;
	[comments release], comments = nil;
    [title release], title = nil;
    [labels release], labels = nil;    
    [body release], body = nil;
    [state release], state = nil;
    [created release], created = nil;
    [updated release], updated = nil;
    [closed release], closed = nil;
	[super dealloc];
}

- (BOOL)isNew {
	return !num ? YES : NO;
}

- (BOOL)isOpen {
	return [state isEqualToString:kIssueStateOpen];
}

- (BOOL)isClosed {
	return [state isEqualToString:kIssueStateClosed];
}

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// num which isn't always available in advance
    return [NSString stringWithFormat:kIssueFormat, repository.owner, repository.name, num];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
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
	if (!repository) {
		NSString *owner = [theDict valueForKeyPath:@"repository.owner.login" defaultsTo:nil];
		NSString *name = [theDict valueForKeyPath:@"repository.name" defaultsTo:nil];
		if (owner && name) {
			self.repository = [GHRepository repositoryWithOwner:owner andName:name];
		}
	}
}

#pragma mark State toggling

- (void)closeIssue {
	self.state = kIssueStateClosed;
	[self saveData];
}

- (void)reopenIssue {
	self.state = kIssueStateOpen;
	[self saveData];
}

#pragma mark Saving

- (void)saveData {
	NSString *path;
	NSString *method;
	if (self.isNew) {
		path = [NSString stringWithFormat:kIssueOpenFormat, repository.owner, repository.name];
		method = @"POST";
	} else {
		path = [NSString stringWithFormat:kIssueEditFormat, repository.owner, repository.name, num];
		method = @"PATCH";
	}
	NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", body, @"body", state, @"state", nil];
	[self saveValues:values withPath:path andMethod:method useResult:^(id theResponse) {
		[self setValuesFromDict:theResponse];
	}];
}

@end
