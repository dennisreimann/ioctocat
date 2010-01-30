#import "GHIssue.h"
#import "GHIssuesParserDelegate.h"


@interface GHIssue ()
- (void)setIssueState:(NSString *)theState;
- (void)toggledIssueStateTo:(id)theResult;
- (void)sendIssueDataToURL:(NSURL *)theURL;
- (void)receiveIssueData:(id)theResult;
@end


@implementation GHIssue

@synthesize user;
@synthesize title;
@synthesize body;
@synthesize state;
@synthesize type;
@synthesize votes;
@synthesize created;
@synthesize updated;
@synthesize num;
@synthesize repository;

- (void)dealloc {
    [user release];
    [title release];
    [type release];    
    [body release];
    [state release];
    [created release];
    [updated release];
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
	id result;
	if ([request error]) {
		result = [request error];
	} else {
		result = [theToggle isEqualToString:kIssueToggleClose] ? kIssueStateClosed : kIssueStateOpen;
	}
	[self performSelectorOnMainThread:@selector(toggledIssueStateTo:) withObject:result waitUntilDone:YES];
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
