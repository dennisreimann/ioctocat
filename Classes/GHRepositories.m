#import "GHRepositories.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "ASIFormDataRequest.h"
#import "GHReposParserDelegate.h"


@implementation GHRepositories

@synthesize user;
@synthesize repositories;

+ (id)repositoriesWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithUser:theUser andURL:theURL] autorelease];
}

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
    [super init];
    self.user = theUser;
    self.resourceURL = theURL;
	self.repositories = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[repositories release], repositories = nil;
	[user release], user = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepositories user:'%@' resourceURL:'%@'>", user, resourceURL];
}

- (void)parseData:(NSData *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];	
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
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		[theResult sortUsingSelector:@selector(compareByName:)];
		self.repositories = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
