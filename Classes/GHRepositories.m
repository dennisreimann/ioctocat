#import "GHRepositories.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "GHReposParserDelegate.h"


@interface GHRepositories ()
- (void)parseRepositories;
- (void)loadedRepositories:(id)theResult;
@end


@implementation GHRepositories

@synthesize user, repositories, repositoriesURL;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
    [super init];
    self.user = theUser;
	self.repositories = [NSMutableArray array];
    self.repositoriesURL = theURL;
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	[super init];
	self.user = [coder decodeObjectForKey:kUserKey];
	self.repositories = [coder decodeObjectForKey:kRepositoriesKey];
	self.repositoriesURL = [coder decodeObjectForKey:kRepositoriesURLKey];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:user forKey:kUserKey];
	[coder encodeObject:repositories forKey:kRepositoriesKey];
	[coder encodeObject:repositoriesURL forKey:kRepositoriesURLKey];
}

- (void)dealloc {
	[repositoriesURL release];
	[repositories release];
	[user release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepositories user:'%@' repositoriesURL:'%@'>", user, repositoriesURL];
}

- (void)loadRepositories {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseRepositories) withObject:nil];
}

- (void)parseRepositories {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:repositoriesURL];    
	[request start];
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedRepositories:)];
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

- (void)loadedRepositories:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		[theResult sortUsingSelector:@selector(compareByName:)];
		self.repositories = theResult;
		self.status = GHResourceStatusLoaded;
	}
}

@end
