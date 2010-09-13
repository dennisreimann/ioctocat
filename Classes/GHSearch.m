#import "GHSearch.h"


@implementation GHSearch

@synthesize results;
@synthesize searchTerm;

+ (id)searchWithURLFormat:(NSString *)theFormat andParserDelegateClass:(Class)theDelegateClass {
	return [[[[self class] alloc] initWithURLFormat:theFormat andParserDelegateClass:theDelegateClass] autorelease];
}

- (id)initWithURLFormat:(NSString *)theFormat andParserDelegateClass:(Class)theDelegateClass {
	[super init];
	urlFormat = [theFormat retain];
	parserDelegate = [(GHResourcesParserDelegate *)[theDelegateClass alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
	return self;
}

- (void)dealloc {
	[parserDelegate release], parserDelegate = nil;
	[searchTerm release], searchTerm = nil;
	[urlFormat release], urlFormat = nil;
	[results release], results = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHSearch searchTerm:'%@' resourceURL:'%@'>", searchTerm, self.resourceURL];
}

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// searchTerm which isn't always available in advance
	NSString *encodedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:urlFormat, encodedSearchTerm];
	NSURL *url = [NSURL URLWithString:urlString];
	return url;
}

- (void)parseData:(NSData *)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		// Mark the results as not loaded, because the search doesn't contain all attributes
		for (GHResource *res in theResult) res.loadingStatus = GHResourceStatusNotLoaded;
		self.results = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
