#import "GHUser.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GravatarLoader.h"
#import "GHReposParserDelegate.h"
#import "GHUsersParserDelegate.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@interface GHUser ()
- (void)parseXMLWithToken:(NSString *)token;
- (void)parseReposXML;
@end


@implementation GHUser

@synthesize name, login, email, company, blogURL, location, gravatar, repositoriesStatus, repositories, isAuthenticated;
@synthesize recentActivity, publicGistCount, privateGistCount, publicRepoCount, privateRepoCount, following, followers;

- (id)init {
	[super init];
	[self addObserver:self forKeyPath:kUserLoginKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.repositoriesStatus = GHResourceStatusNotLoaded;
	isAuthenticated = NO;
	gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [UIImage imageWithContentsOfFile:self.cachedGravatarPath];
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:kUserLoginKeyPath];
	[name release];
	[login release];
	[email release];
	[company release];
	[blogURL release];
	[location release];
	[gravatar release];
	[repositories release];
	[gravatarLoader release];
	[recentActivity release];
    [following release];
    [followers release];
    [super dealloc];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;
	// Recent Activity
	NSString *activityFeedURLString = [NSString stringWithFormat:kUserFeedFormat, login];
	NSURL *activityFeedURL = [NSURL URLWithString:activityFeedURLString];
	self.recentActivity = [[[GHFeed alloc] initWithURL:activityFeedURL] autorelease];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserLoginKeyPath]) {
		NSString *newLogin = [(GHUser *)object login];
		NSString *followingURLString = [NSString stringWithFormat:kUserFollowingFormat, newLogin];
		NSString *followersURLString = [NSString stringWithFormat:kUserFollowersFormat, newLogin];
		NSURL *followingURL = [NSURL URLWithString:followingURLString];
		NSURL *followersURL = [NSURL URLWithString:followersURLString];
		self.following = [[[GHUsers alloc] initWithUser:self andURL:followingURL] autorelease];
		self.followers = [[[GHUsers alloc] initWithUser:self andURL:followersURL] autorelease];
	}
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' isAuthenticated:'%@' status:'%d' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@' publicRepoCount:'%d' privateRepoCount:'%d'>", login, isAuthenticated ? @"YES" : @"NO", status, name, email, company, location, blogURL, publicRepoCount, privateRepoCount];
}

#pragma mark -
#pragma mark User loading

- (void)loadUser {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:nil];
}

- (void)authenticateWithToken:(NSString *)theToken {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:theToken];
}

- (void)parseXMLWithToken:(NSString *)token {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *userURLString = token ? [NSString stringWithFormat:kAuthenticateUserXMLFormat, login, login, token] : [NSString stringWithFormat:kUserXMLFormat, login];
	NSURL *userURL = [NSURL URLWithString:userURLString];    
	GHUsersParserDelegate *parserDelegate = [[GHUsersParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedUsers:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:userURL];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedUsers:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
	} else if ([(NSArray *)theResult count] > 0) {
		GHUser *user = [(NSArray *)theResult objectAtIndex:0];
		self.login = user.login;
		self.name = user.name;
		self.email = user.email;
		self.company = user.company;
		self.location = user.location;
		self.blogURL = user.blogURL;
		self.publicGistCount = user.publicGistCount;
		self.privateGistCount = user.privateGistCount;
		self.publicRepoCount = user.publicRepoCount;
		self.privateRepoCount = user.privateRepoCount;
		self.isAuthenticated = user.isAuthenticated;
		if (email) [gravatarLoader loadEmail:email withSize:44];
	}
	self.status = GHResourceStatusLoaded;
}

#pragma mark -
#pragma mark Repository loading

- (BOOL)isReposLoading {
	return repositoriesStatus == GHResourceStatusLoading;
}

- (BOOL)isReposLoaded {
	return repositoriesStatus == GHResourceStatusLoaded;
}

- (void)loadRepositories {
	self.repositoriesStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseReposXML) withObject:nil];
}

- (void)parseReposXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];   
	NSString *url = [NSString stringWithFormat:kUserReposFormat, login];
	NSURL *reposURL = [NSURL URLWithString:url];        
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:reposURL];    
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

- (void)loadedRepositories:(NSArray *)theRepositories {
	self.repositories = [NSMutableArray arrayWithArray:theRepositories];
    [self.repositories sortUsingSelector:@selector(compareByName:)];
	self.repositoriesStatus = GHResourceStatusLoaded;
}

#pragma mark -
#pragma mark Following/Watching


- (BOOL)isFollowing:(GHUser *)anUser {
    if (!following.isLoaded) [following loadUsers];
    for (GHUser *user in following.users) {
        if ([user.login caseInsensitiveCompare:anUser.login] == 0) return YES;
    }
	return NO;
}

// FIXME Currently just stubbed out, see the issue:
// http://github.com/dbloete/ioctocat/issues#issue/6
- (BOOL)isWatching:(GHRepository *)aRepository {
	return NO;
}

- (void)setFollowingState:(NSString *)theState forUser:(GHUser *)theUser {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *followingURLString = [NSString stringWithFormat:kFollowUserFormat, theState, theUser.login];
	NSURL *followingURL = [NSURL URLWithString:followingURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:followingURL];    
	[request start];
	self.following.status = GHResourceStatusNotLoaded;
    [self.following loadUsers];
    [pool release];
}

- (void)setWatchingState:(NSString *)theState forRepository:(GHRepository *)theRepository {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *watchingURLString = [NSString stringWithFormat:kWatchRepoFormat, theState, theRepository.owner,theRepository.name ];
	NSURL *watchingURL = [NSURL URLWithString:watchingURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:watchingURL];    
	[request start];
//  TODO: Implement one the watch list api is available
//	selffollowing.status = GHResourceStatusNotLoaded;
//    [self.following loadUsers];
    [pool release];
}

#pragma mark -
#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:self.cachedGravatarPath atomically:YES];
}

- (NSString *)cachedGravatarPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", login];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

@end
