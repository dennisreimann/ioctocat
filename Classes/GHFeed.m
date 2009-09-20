#import "GHFeed.h"
#import "GHFeedParserDelegate.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"


@interface GHFeed ()
- (void)parseFeed;
@end


@implementation GHFeed

@synthesize url, entries, lastReadingDate;

- (id)initWithURL:(NSURL *)theURL {
	[super init];
	self.url = theURL;
	return self;
}

- (void)dealloc {
	[url release];
	[entries release];
	[lastReadingDate release];
    [super dealloc];
}

- (void)setEntries:(NSArray *)theEntries {
	[theEntries retain];
	[entries release];
	for (GHFeedEntry *entry in theEntries) {
		if ([entry.date compare:lastReadingDate] != NSOrderedDescending) entry.read = YES;
	}
	entries = theEntries;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeed url:'%@'>", url];
}

#pragma mark -
#pragma mark Feed parsing

- (void)loadEntries {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseFeed) withObject:nil];
}

- (void)parseFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:url];
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
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		self.entries = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
