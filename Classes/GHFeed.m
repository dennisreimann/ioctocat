#import "GHFeed.h"
#import "GHFeedParserDelegate.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"


@interface GHFeed ()
- (void)parseFeed;
@end


@implementation GHFeed

@synthesize url, entries;

- (id)initWithURL:(NSURL *)theURL {
	[super init];
	self.url = theURL;
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeed url:'%@'>", url];
}

#pragma mark -
#pragma mark Feed parsing

- (void)loadEntries {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseFeed) withObject:nil];
}

- (void)parseFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ASIFormDataRequest *request = [self authenticatedRequestForUrl:url];
	[request start];
	GHFeedParserDelegate *parserDelegate = [[GHFeedParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedEntries:)];
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

- (void)loadedEntries:(id)theResult {
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
