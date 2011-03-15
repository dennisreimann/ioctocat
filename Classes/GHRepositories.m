#import "GHRepositories.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "ASIFormDataRequest.h"
#import "GHReposParserDelegate.h"


@implementation GHRepositories

@synthesize repositories;

+ (id)repositoriesWithURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
    [super init];
    self.resourceURL = theURL;
	self.repositories = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[repositories release], repositories = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepositories resourceURL:'%@'>", resourceURL];
}

- (void)parseData:(NSData *)theData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
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
	} else {
		[theResult sortUsingSelector:@selector(compareByName:)];
		self.repositories = theResult;
		self.loadingStatus = GHResourceStatusProcessed;
	}
}

@end
