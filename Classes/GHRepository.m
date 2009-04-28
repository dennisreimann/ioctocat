#import "GHRepository.h"
#import "iOctocatAppDelegate.h"
#import "GHReposParserDelegate.h"
#import "GHCommitsParserDelegate.h"


@interface GHRepository ()
- (void)parseXML;
@end


@implementation GHRepository

@synthesize user, name, owner, descriptionText, githubURL, homepageURL, isPrivate, isFork, forks, watchers, recentCommits;

- (id)init {
	[super init];
	self.status = GHResourceStatusNotLoaded;
	return self;
}

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	[self init];
	[self setOwner:theOwner andName:theName];
	return self;
}

- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName {
	self.owner = theOwner;
	self.name = theName;
	NSString *commitFeedURLString = [NSString stringWithFormat:kRepoFeedFormat, owner, name];
	NSURL *commitFeedURL = [NSURL URLWithString:commitFeedURLString];
	GHFeed *commitFeed = [[GHFeed alloc] initWithURL:commitFeedURL];
	self.recentCommits = commitFeed;
	[commitFeed release];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forks, watchers];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:owner];
}

#pragma mark -
#pragma mark Repository loading

- (void)loadRepository {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
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

- (void)loadedRepositories:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.status = GHResourceStatusLoaded;
		if ([(NSArray *)theResult count] == 0) return;
		GHRepository *repo = [(NSArray *)theResult objectAtIndex:0];
		self.descriptionText = repo.descriptionText;
		self.githubURL = repo.githubURL;
		self.homepageURL = repo.homepageURL;
		self.isFork = repo.isFork;
		self.isPrivate = repo.isPrivate;
		self.forks = repo.forks;
		self.watchers = repo.watchers;
		self.status = GHResourceStatusLoaded;
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
	[recentCommits release];
    [super dealloc];
}

@end
