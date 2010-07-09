#import "GHUser.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GravatarLoader.h"
#import "GHReposParserDelegate.h"
#import "GHUsersParserDelegate.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "NSString+Extensions.h"


@interface GHUser ()
- (void)parseXMLWithToken:(NSString *)token;
- (void)setUserFollowing:(NSArray *)args;
- (void)setRepositoryWatching:(NSArray *)args;
@end


@implementation GHUser

@synthesize name;
@synthesize login;
@synthesize email;
@synthesize company;
@synthesize blogURL;
@synthesize location;
@synthesize gravatarHash;
@synthesize searchTerm;
@synthesize gravatar;
@synthesize repositories;
@synthesize watchedRepositories;
@synthesize isAuthenticated;
@synthesize recentActivity;
@synthesize publicGistCount;
@synthesize privateGistCount;
@synthesize publicRepoCount;
@synthesize privateRepoCount;
@synthesize following;
@synthesize followers;

+ (id)userForSearchTerm:(NSString *)theSearchTerm {
	GHUser *user = [[[GHUser alloc] init] autorelease];
	user.searchTerm = theSearchTerm;
	return user;
}

+ (id)userWithLogin:(NSString *)theLogin {
	return [[[GHUser alloc] initWithLogin:theLogin] autorelease];
}

- (id)init {
	[super init];
	[self addObserver:self forKeyPath:kUserLoginKeyPath options:NSKeyValueObservingOptionNew context:nil];
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
	[gravatarHash release];
	[searchTerm release];
	[gravatar release];
	[repositories release];
	[watchedRepositories release];
	[gravatarLoader release];
	[recentActivity release];
    [following release];
    [followers release];
    [super dealloc];
}

- (NSUInteger)hash {
	NSString *hashValue = [login lowercaseString];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' isAuthenticated:'%@' status:'%d' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@' publicRepoCount:'%d' privateRepoCount:'%d'>", login, isAuthenticated ? @"YES" : @"NO", loadingStatus, name, email, company, location, blogURL, publicRepoCount, privateRepoCount];
}

- (int)compareByName:(GHUser *)theOtherUser {
    return [login localizedCaseInsensitiveCompare:[theOtherUser login]];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;
	// Repositories
	NSString *repositoriesURLString = [NSString stringWithFormat:kUserReposFormat, login];
	NSString *watchedRepositoriesURLString = [NSString stringWithFormat:kUserWatchedReposFormat, login];
	NSURL *repositoriesURL = [NSURL URLWithString:repositoriesURLString];
	NSURL *watchedRepositoriesURL = [NSURL URLWithString:watchedRepositoriesURLString];
	self.repositories = [[[GHRepositories alloc] initWithUser:self andURL:repositoriesURL] autorelease];
	self.watchedRepositories = [[[GHRepositories alloc] initWithUser:self andURL:watchedRepositoriesURL] autorelease];
	// Recent Activity
	NSString *activityFeedURLString = [NSString stringWithFormat:kUserFeedFormat, login];
	NSURL *activityFeedURL = [NSURL URLWithString:activityFeedURLString];
	self.recentActivity = [[[GHFeed alloc] initWithURL:activityFeedURL] autorelease];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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

#pragma mark User loading

- (void)loadUser {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:nil];
}

- (void)authenticateWithToken:(NSString *)theToken {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:theToken];
}

- (void)parseXMLWithToken:(NSString *)token {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *userURLString;
	if (login) {
		userURLString = token ? [NSString stringWithFormat:kAuthenticateUserXMLFormat, login, login, token] : [NSString stringWithFormat:kUserXMLFormat, login];
	} else {
		userURLString = [NSString stringWithFormat:kUserSearchFormat, searchTerm];
	}
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
		if (!login || [login isEmpty]) self.login = user.login;
		self.name = user.name;
		self.email = user.email;
		self.company = user.company;
		self.location = user.location;
		self.gravatarHash = user.gravatarHash;
		self.blogURL = user.blogURL;
		self.publicGistCount = user.publicGistCount;
		self.privateGistCount = user.privateGistCount;
		self.publicRepoCount = user.publicRepoCount;
		self.privateRepoCount = user.privateRepoCount;
		self.isAuthenticated = user.isAuthenticated;
		if (gravatarHash) [gravatarLoader loadHash:gravatarHash withSize:44];
		else if (email) [gravatarLoader loadEmail:email withSize:44];
	}
	self.loadingStatus = GHResourceStatusLoaded;
}

#pragma mark Following/Watching

- (BOOL)isFollowing:(GHUser *)anUser {
	if (!following.isLoaded) [following loadData];
	return [following.users containsObject:anUser];
}

- (void)followUser:(GHUser *)theUser {
	[following.users addObject:theUser];
	NSArray *args = [NSArray arrayWithObjects:theUser, kFollow, nil];
	[self performSelectorInBackground:@selector(setUserFollowing:) withObject:args];
}

- (void)unfollowUser:(GHUser *)theUser {
	[following.users removeObject:theUser];
	NSArray *args = [NSArray arrayWithObjects:theUser, kUnFollow, nil];
	[self performSelectorInBackground:@selector(setUserFollowing:) withObject:args];
}

- (void)setUserFollowing:(NSArray *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHUser *user = [args objectAtIndex:0];
	NSString *state = [args objectAtIndex:1];
	NSString *followingURLString = [NSString stringWithFormat:kFollowUserFormat, state, user.login];
	NSURL *followingURL = [NSURL URLWithString:followingURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:followingURL];    
	[request start];
	self.following.loadingStatus = GHResourceStatusNotLoaded;
    [self.following loadData];
    [pool release];
}

- (BOOL)isWatching:(GHRepository *)aRepository {
	if (!watchedRepositories.isLoaded) [watchedRepositories loadData];
	return [watchedRepositories.repositories containsObject:aRepository];
}

- (void)watchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories addObject:theRepository];
	NSArray *args = [NSArray arrayWithObjects:theRepository, kWatch, nil];
	[self performSelectorInBackground:@selector(setRepositoryWatching:) withObject:args];
}

- (void)unwatchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories removeObject:theRepository];
	NSArray *args = [NSArray arrayWithObjects:theRepository, kUnWatch, nil];
	[self performSelectorInBackground:@selector(setRepositoryWatching:) withObject:args];
}

- (void)setRepositoryWatching:(NSArray *)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHRepository *repo = [args objectAtIndex:0];
	NSString *state = [args objectAtIndex:1];
	NSString *watchingURLString = [NSString stringWithFormat:kWatchRepoFormat, state, repo.owner, repo.name];
	NSURL *watchingURL = [NSURL URLWithString:watchingURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:watchingURL];    
	[request start];
    [pool release];
}

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
