#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"
#import "GHReposParserDelegate.h"


@interface GHRepository ()
- (void)parseXML;
- (void)loadedRepositories:(NSArray *)theRepositories;
@end


@implementation GHRepository

@synthesize user, name, owner, descriptionText, githubURL, homepageURL, isPrivate, isFork, forks, watchers, isLoaded, isLoading;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	if (self = [super init]) {
		self.owner = theOwner;
		self.name = theName;
		self.isLoaded = NO;
		self.isLoading = NO;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository isLoaded:'%@' name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", isLoaded ? @"YES" : @"NO", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forks, watchers];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:owner];
}

- (void)loadRepository {
	self.isLoaded = NO;
	self.isLoading = YES;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)parseXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kRepoXMLFormat, owner, name];
	NSURL *repoURL = [NSURL URLWithString:url];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:repoURL];
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedRepositories:)];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedRepositories:(NSArray *)theRepositories {
	if (theRepositories.count == 0) return;
	GHRepository *repo = [theRepositories objectAtIndex:0];
	self.descriptionText = repo.descriptionText;
	self.githubURL = repo.githubURL;
	self.homepageURL = repo.homepageURL;
	self.isFork = repo.isFork;
	self.isPrivate = repo.isPrivate;
	self.forks = repo.forks;
	self.watchers = repo.watchers;
	self.isLoaded = YES;
	self.isLoading = NO;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
    [super dealloc];
}

@end
