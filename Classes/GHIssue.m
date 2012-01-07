#import "GHIssue.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"
#import "NSURL+Extensions.h"


@interface GHIssue ()
// Saving
- (void)setIssueState:(NSString *)theState;
- (void)toggledIssueStateTo:(id)theResult;
@end


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

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// num which isn't always available in advance
	return [NSURL URLWithFormat:kIssueFormat, repository.owner, repository.name, num];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
	NSDictionary *resource = [theDict objectForKey:@"issue"] ? [theDict objectForKey:@"issue"] : theDict;
	NSString *login = [[resource objectForKey:@"user"] objectForKey:@"login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.created = [iOctocat parseDate:[resource objectForKey:@"created_at"] withFormat:kISO8601TimeFormat];
	self.updated = [iOctocat parseDate:[resource objectForKey:@"updated_at"] withFormat:kISO8601TimeFormat];
	self.closed = [iOctocat parseDate:[resource objectForKey:@"closed_at"] withFormat:kISO8601TimeFormat];
	self.title = [resource objectForKey:@"title"];
	self.body = [resource objectForKey:@"body"];
	self.state = [resource objectForKey:@"state"];
    self.labels = [resource objectForKey:@"labels"];
	self.votes = [[resource objectForKey:@"votes"] integerValue];
	self.num = [[resource objectForKey:@"number"] integerValue];
}

#pragma mark State toggling

- (void)closeIssue {
	[self setIssueState:kIssueToggleClose];
}

- (void)reopenIssue {
	[self setIssueState:kIssueToggleReopen];
}

- (void)setIssueState:(NSString *)theToggle {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	NSURL *url = [NSURL URLWithFormat:kIssueToggleFormat, theToggle, repository.owner, repository.name, num];
	// Send the request
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(stateTogglingFinished:)];
	[request setDidFailSelector:@selector(stateTogglingFailed:)];
	DJLog(@"Sending save request: %@", request);
	[[iOctocat queue] addOperation:request];
}

- (void)stateTogglingFinished:(ASIHTTPRequest *)request {
	[self performSelectorInBackground:@selector(parseToggleData:) withObject:[request responseData]];
}

- (void)stateTogglingFailed:(ASIHTTPRequest *)request {
	DJLog(@"Save request for url '%@' failed: %@", [request url], [request error]);
	[self toggledIssueStateTo:[request error]];
}

- (void)parseToggleData:(NSData *)theData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserialize:theData error:&parseError];
	id res = parseError ? (id)parseError : (id)[resultDict valueForKeyPath:@"issue.state"];
	[self performSelectorOnMainThread:@selector(toggledIssueStateTo:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)toggledIssueStateTo:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotProcessed;
	} else {
		self.state = theResult;
		self.savingStatus = GHResourceStatusProcessed;
	}
}

#pragma mark Saving

- (void)saveData {
	NSURL *url;
	if (self.isNew) {
		url = [NSURL URLWithFormat:kIssueOpenFormat, repository.owner, repository.name];
	} else {
		url = [NSURL URLWithFormat:kIssueEditFormat, repository.owner, repository.name, num];
	}
	NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:title, kIssueTitleParamName, body, kIssueBodyParamName, nil];
	[self saveValues:values withURL:url];
}

@end
