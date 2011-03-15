#import "GHIssue.h"
#import "GHIssuesParserDelegate.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"


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
@synthesize type;
@synthesize votes;
@synthesize created;
@synthesize updated;
@synthesize num;
@synthesize repository;

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
    [type release], type = nil;    
    [body release], body = nil;
    [state release], state = nil;
    [created release], created = nil;
    [updated release], updated = nil;
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
	NSString *urlString = [NSString stringWithFormat:kRepoIssueXMLFormat, repository.owner, repository.name, num];
	return [NSURL URLWithString:urlString];
}

#pragma mark Loading

- (void)parseData:(NSData *)theData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHIssuesParserDelegate *parserDelegate = [[GHIssuesParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
	parserDelegate.repository = repository;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:theData];	
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotProcessed;
	} else if ([(NSArray *)theResult count] > 0) {
		GHIssue *issue = [(NSArray *)theResult objectAtIndex:0];
		self.user = issue.user;
		self.title = issue.title;
		self.body = issue.body;
		self.state = issue.state;
		self.type = issue.type;
		self.created = issue.created;
		self.updated = issue.updated;
		self.votes = issue.votes;
		self.num = issue.num;
		self.loadingStatus = GHResourceStatusProcessed;
	}
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
	NSString *urlString = [NSString stringWithFormat:kIssueToggleFormat, theToggle, repository.owner, repository.name, num];
	NSURL *url = [NSURL URLWithString:urlString];
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
	NSString *urlString;
	if (self.isNew) {
		urlString = [NSString stringWithFormat:kOpenIssueXMLFormat, repository.owner, repository.name];
	} else {
		urlString = [NSString stringWithFormat:kEditIssueXMLFormat, repository.owner, repository.name, num];
	}
	NSURL *url = [NSURL URLWithString:urlString];
	NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:title, kIssueTitleParamName, body, kIssueBodyParamName, nil];
	[self saveValues:values withURL:url];
}

- (void)parseSaveData:(NSData *)theData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHIssuesParserDelegate *parserDelegate = [[GHIssuesParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingSaveFinished:)];
	parserDelegate.repository = repository;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:theData];	
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)parsingSaveFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotProcessed;
	} else if ([(NSArray *)theResult count] > 0) {
		GHIssue *issue = [(NSArray *)theResult objectAtIndex:0];
		self.user = issue.user;
		self.title = issue.title;
		self.body = issue.body;
		self.state = issue.state;
		self.type = issue.type;
		self.created = issue.created;
		self.updated = issue.updated;
		self.votes = issue.votes;
		self.num = issue.num;
		self.savingStatus = GHResourceStatusProcessed;
	}
}

@end
