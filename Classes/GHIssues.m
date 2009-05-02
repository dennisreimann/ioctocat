#import "GHIssues.h"
#import "GHIssuesParserDelegate.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"


@interface GHIssues ()
- (void)parseIssues;
@end


@implementation GHIssues

@synthesize url, entries;

- (id)initWithURL:(NSURL *)theURL {
	[super init];
	self.url = theURL;
	self.status = GHResourceStatusNotLoaded;
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssues url:'%@'>", url];
}

#pragma mark -
#pragma mark Issues parsing

- (void)loadIssues {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseIssues) withObject:nil];
}

- (void)parseIssues {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:username forKey:@"login"];
	[request setPostValue:token forKey:@"token"];	
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
		self.status = GHResourceStatusLoaded;
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[url release];
	[entries release];
    [super dealloc];
}

@end
