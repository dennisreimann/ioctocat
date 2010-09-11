#import "GHRepository.h"
#import "iOctocat.h"
#import "GHReposParserDelegate.h"
#import "GHCommitsParserDelegate.h"
#import "GHIssues.h"
#import "GHNetworks.h"
#import "GHBranches.h"


@implementation GHRepository

@synthesize name;
@synthesize owner;
@synthesize descriptionText;
@synthesize githubURL;
@synthesize homepageURL;
@synthesize isPrivate;
@synthesize isFork;
@synthesize forks;
@synthesize watchers;
@synthesize openIssues;
@synthesize closedIssues;
@synthesize networks;
@synthesize branches;

+ (id)repositoryWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	return [[[[self class] alloc] initWithOwner:theOwner andName:theName] autorelease];
}

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	[super init];
	[self setOwner:theOwner andName:theName];
	return self;
}

- (void)dealloc {
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
    [openIssues release];
    [closedIssues release];
    [networks release];
	[branches release];
    [super dealloc];
}

- (BOOL)isEqual:(id)anObject {
	return [self hash] == [anObject hash];
}

- (NSUInteger)hash {
	NSString *hashValue = [NSString stringWithFormat:@"%@/%@", [owner lowercaseString], [name lowercaseString]];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forks, watchers];
}

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// owner and name which isn't always available in advance
	NSString *urlString = [NSString stringWithFormat:kRepoXMLFormat, owner, name];
	return [NSURL URLWithString:urlString];
}

- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName {
	self.owner = theOwner;
	self.name = theName;
    // Networks
    self.networks = [[[GHNetworks alloc] initWithRepository:self] autorelease];
	// Branches
    self.branches = [[[GHBranches alloc] initWithRepository:self] autorelease];
	// Issues
	self.openIssues = [[[GHIssues alloc] initWithRepository:self andState:kIssueStateOpen] autorelease];
	self.closedIssues = [[[GHIssues alloc] initWithRepository:self andState:kIssueStateClosed] autorelease];
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:owner];
}

- (int)compareByName:(GHRepository *)theOtherRepository {
    return [[self name] localizedCaseInsensitiveCompare:[theOtherRepository name]];
}

#pragma mark Repository loading

- (void)parseData:(NSData *)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];	
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
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
		self.loadingStatus = GHResourceStatusLoaded;
		if ([(NSArray *)theResult count] == 0) return;
		GHRepository *repo = [(NSArray *)theResult objectAtIndex:0];
		self.descriptionText = repo.descriptionText;
		self.githubURL = repo.githubURL;
		self.homepageURL = repo.homepageURL;
		self.isFork = repo.isFork;
		self.isPrivate = repo.isPrivate;
		self.forks = repo.forks;
		self.watchers = repo.watchers;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
