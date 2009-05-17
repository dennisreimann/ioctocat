#import "GHSearch.h"


@implementation GHSearch

@synthesize results;

- (id)initWithURLFormat:(NSString *)theFormat andParserDelegateClass:(Class)theDelegateClass {
	[super init];
	urlFormat = [theFormat retain];
	parserDelegate = [(GHResourcesParserDelegate *)[theDelegateClass alloc] initWithTarget:self andSelector:@selector(loadedResults:)];
	return self;
}

- (void)dealloc {
	[parserDelegate release];
	[searchTerm release];
	[urlFormat release];
	[results release];
    [super dealloc];
}

- (NSString *)searchTerm {
	return searchTerm;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHSearch searchTerm:'%@' urlFormat:'%@'>", searchTerm, urlFormat];
}

- (void)loadResultsForSearchTerm:(NSString *)theSearchTerm {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[theSearchTerm retain];
	[searchTerm release];
	searchTerm = theSearchTerm;
	NSString *encodedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *searchURLString = [NSString stringWithFormat:urlFormat, encodedSearchTerm];
	NSURL *searchURL = [NSURL URLWithString:searchURLString];
	[self performSelectorInBackground:@selector(parseSearchAtURL:) withObject:searchURL];
}

- (void)parseSearchAtURL:(NSURL *)theSearchURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:theSearchURL];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

- (void)loadedResults:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		// Mark the results as not loaded, because the search doesn't contain all attributes
		for (GHResource *result in theResult) result.status = GHResourceStatusNotLoaded;
		self.results = theResult;
		self.status = GHResourceStatusLoaded;
	}
}

@end
