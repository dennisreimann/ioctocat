#import "GHIssue.h"
#import "GHIssuesParserDelegate.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"


@interface GHIssue ()
// Loading
- (void)parseIssue;
- (void)loadedIssue:(id)theResult;
// Saving
- (void)setIssueState:(NSString *)theState;
- (void)toggledIssueStateTo:(id)theResult;
- (void)sendIssueDataToURL:(NSURL *)theURL;
- (void)receiveIssueData:(id)theResult;
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

#pragma mark Loading

- (void)loadIssue {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseIssue) withObject:nil];
}

- (void)parseIssue {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *urlString = [NSString stringWithFormat:kRepoIssueXMLFormat, repository.owner, repository.name, num];
	NSURL *issueURL = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:issueURL];
	[request start];	
	GHIssuesParserDelegate *parserDelegate = [[GHIssuesParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedIssue:)];
	parserDelegate.repository = repository;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];	
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedIssue:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
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
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

#pragma mark Saving

- (void)closeIssue {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusSaving;
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleClose];
}

- (void)reopenIssue {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusSaving;
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleReopen];
}

- (void)setIssueState:(NSString *)theToggle {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *toggleURLString = [NSString stringWithFormat:kIssueToggleFormat, theToggle, repository.owner, repository.name, num];
	NSURL *toggleURL = [NSURL URLWithString:toggleURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:toggleURL];    
	[request start];
	id res;
	if ([request error]) {
		res = [request error];
	} else {
		res = [theToggle isEqualToString:kIssueToggleClose] ? kIssueStateClosed : kIssueStateOpen;
	}
	[self performSelectorOnMainThread:@selector(toggledIssueStateTo:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)toggledIssueStateTo:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotSaved;
	} else {
		self.state = theResult;
		self.savingStatus = GHResourceStatusSaved;
	}
}

- (void)saveIssue {
	if (self.isSaving) return;
	NSString *saveURLString;
	if (self.isNew) {
		saveURLString = [NSString stringWithFormat:kOpenIssueXMLFormat, repository.owner, repository.name];
	} else {
		saveURLString = [NSString stringWithFormat:kEditIssueXMLFormat, repository.owner, repository.name, num];
	}
	NSURL *saveURL = [NSURL URLWithString:saveURLString];
	self.error = nil;
	self.savingStatus = GHResourceStatusSaving;
	[self performSelectorInBackground:@selector(sendIssueDataToURL:) withObject:saveURL];
}

- (void)sendIssueDataToURL:(NSURL *)theURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:theURL];
	[request setPostValue:title forKey:kIssueTitleParamName];
	[request setPostValue:body forKey:kIssueBodyParamName];
	[request start];	
	GHIssuesParserDelegate *parserDelegate = [[GHIssuesParserDelegate alloc] initWithTarget:self andSelector:@selector(receiveIssueData:)];
	parserDelegate.repository = repository;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];	
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)receiveIssueData:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotSaved;
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
		self.savingStatus = GHResourceStatusSaved;
	}
}

@end
