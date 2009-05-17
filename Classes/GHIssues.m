#import "GHIssues.h"
#import "GHIssuesParserDelegate.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"


@interface GHIssues ()
- (void)parseIssues;
@end


@implementation GHIssues

@synthesize entries, repository, issueState;

- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
    [super init];
    self.repository = theRepository;
    self.issueState = theState;
	return self;    
}

- (void)dealloc {
	[repository release];
	[issueState release];
	[entries release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssues repository:'%@' state:'%@'>", repository, issueState];
}

- (void)loadIssues {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseIssues) withObject:nil];
}

- (void)parseIssues {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *issuesURLString = [NSString stringWithFormat:kRepoIssuesXMLFormat, repository.owner, repository.name, issueState];
	NSURL *issuesURL = [NSURL URLWithString:issuesURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:issuesURL];
	[request start];	
	GHIssuesParserDelegate *parserDelegate = [[GHIssuesParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedIssues:)];
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

- (void)loadedIssues:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.entries = theResult;
		for (GHIssue *issue in theResult) issue.repository = repository;
		self.status = GHResourceStatusLoaded;
	}
}

@end
