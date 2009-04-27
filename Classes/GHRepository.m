#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"
#import "GHReposParserDelegate.h"
#import "GHCommitsParserDelegate.h"


@interface GHRepository ()
- (void)parseXML;
- (void)parseRecentCommitsXML;
@end


@implementation GHRepository

@synthesize user, name, owner, descriptionText, githubURL, homepageURL, isPrivate, isFork;
@synthesize forks, watchers, recentCommits, isRecentCommitsLoaded, isRecentCommitsLoading;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	if (self = [super init]) {
		self.owner = theOwner;
		self.name = theName;
		self.status = GHResourceStatusNotLoaded;
		self.isRecentCommitsLoaded = NO;
		self.isRecentCommitsLoading = NO;
	}
	return self;
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
	self.status = GHResourceStatusLoaded;
}

#pragma mark -
#pragma mark Commit loading

- (void)loadRecentCommits {
	self.isRecentCommitsLoaded = NO;
	self.isRecentCommitsLoading = YES;
	[self performSelectorInBackground:@selector(parseRecentCommitsXML) withObject:nil];
}

- (void)parseRecentCommitsXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kRepoCommitsXMLFormat, owner, name, @"master"];
	NSURL *commitsURL = [NSURL URLWithString:url];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:commitsURL];
	GHCommitsParserDelegate *parserDelegate = [[GHCommitsParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedRecentCommits:)];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedRecentCommits:(NSArray *)theCommits {
	if (theCommits.count == 0) return;
	self.recentCommits = theCommits;
	self.isRecentCommitsLoaded = YES;
	self.isRecentCommitsLoading = NO;
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
