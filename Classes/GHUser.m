#import "GHUser.h"
#import "GHUsers.h"
#import "GHOrganizations.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHResource.h"
#import "GravatarLoader.h"
#import "ASIFormDataRequest.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"


@interface GHUser ()
- (void)setFollowing:(BOOL)theMode forUser:(GHUser *)theUser;
- (void)setWatching:(BOOL)theMode forRepository:(GHRepository *)theRepository;
- (void)setStarring:(BOOL)theMode forRepository:(GHRepository *)theRepository;
- (void)setStarring:(BOOL)theMode forGist:(GHGist *)theGist;
- (void)followToggleFinished:(ASIHTTPRequest *)request;
- (void)followToggleFailed:(ASIHTTPRequest *)request;
- (void)watchToggleFinished:(ASIHTTPRequest *)request;
- (void)watchToggleFailed:(ASIHTTPRequest *)request;
- (void)starToggleFinished:(ASIHTTPRequest *)request;
- (void)starToggleFailed:(ASIHTTPRequest *)request;
- (void)gistStarToggleFinished:(ASIHTTPRequest *)request;
- (void)gistStarToggleFailed:(ASIHTTPRequest *)request;
@end


@implementation GHUser

@synthesize name;
@synthesize login;
@synthesize email;
@synthesize company;
@synthesize blogURL;
@synthesize location;
@synthesize gravatarURL;
@synthesize htmlURL;
@synthesize gravatar;
@synthesize organizations;
@synthesize repositories;
@synthesize starredRepositories;
@synthesize watchedRepositories;
@synthesize isAuthenticated;
@synthesize recentActivity;
@synthesize publicGistCount;
@synthesize privateGistCount;
@synthesize publicRepoCount;
@synthesize privateRepoCount;
@synthesize followingCount;
@synthesize followersCount;
@synthesize following;
@synthesize followers;
@synthesize gists;
@synthesize starredGists;

+ (id)userWithLogin:(NSString *)theLogin {
	return [[[[self class] alloc] initWithLogin:theLogin] autorelease];
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [iOctocat cachedGravatarForIdentifier:self.login];
	self.isAuthenticated = NO;
	gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[login release], login = nil;
	[email release], email = nil;
	[company release], company = nil;
	[blogURL release], blogURL = nil;
	[location release], location = nil;
    [gravatarLoader release], gravatarLoader = nil;
	[gravatarURL release], gravatarURL = nil;
	[htmlURL release], htmlURL = nil;
	[gravatar release], gravatar = nil;
	[organizations release], organizations = nil;
	[repositories release], repositories = nil;
	[watchedRepositories release], watchedRepositories = nil;
	[recentActivity release], recentActivity = nil;
    [following release], following = nil;
    [followers release], followers = nil;
    [super dealloc];
}

- (NSUInteger)hash {
	NSString *hashValue = [login lowercaseString];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' isAuthenticated:'%@' status:'%d'>", login, isAuthenticated ? @"YES" : @"NO", loadingStatus];
}

- (int)compareByName:(GHUser *)theOtherUser {
    return [login localizedCaseInsensitiveCompare:[theOtherUser login]];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;
    
    NSString *repositoriesPath  = [NSString stringWithFormat:kUserReposFormat, login];
	NSString *organizationsPath = [NSString stringWithFormat:kUserOrganizationsFormat, login];
	NSString *watchedReposPath  = [NSString stringWithFormat:kUserWatchedReposFormat, login];
	NSString *starredReposPath  = [NSString stringWithFormat:kUserStarredReposFormat, login];
    NSString *followingPath     = [NSString stringWithFormat:kUserFollowingFormat, login];
    NSString *followersPath     = [NSString stringWithFormat:kUserFollowersFormat, login];
	NSString *activityFeedPath  = [NSString stringWithFormat:kUserFeedFormat, login];
	NSString *gistsPath         = [NSString stringWithFormat:kUserGistsFormat, login];
	NSString *starredGistsPath  = [NSString stringWithFormat:kStarredGistsFormat];

    self.resourcePath = [NSString stringWithFormat:kUserFormat, login];
	self.organizations = [GHOrganizations organizationsWithUser:self andPath:organizationsPath];
	self.repositories = [GHRepositories repositoriesWithPath:repositoriesPath];
	self.starredRepositories = [GHRepositories repositoriesWithPath:starredReposPath];
	self.watchedRepositories = [GHRepositories repositoriesWithPath:watchedReposPath];
    self.following = [GHUsers usersWithPath:followingPath];
    self.followers = [GHUsers usersWithPath:followersPath];
    self.gists = [GHGists gistsWithPath:gistsPath];
    self.starredGists = [GHGists gistsWithPath:starredGistsPath];
	self.recentActivity = [GHFeed resourceWithPath:activityFeedPath];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
    if (![login isEqualToString:[theDict objectForKey:@"login"]]) self.login = [theDict objectForKey:@"login"];
    self.name = [[theDict objectForKey:@"name"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"name"];
    NSString *mail = [theDict objectForKey:@"email"];
    if (![mail isKindOfClass:[NSNull class]] && ![mail isEmpty]) {
        self.email = mail;
    }
    self.company = [[theDict objectForKey:@"company"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"company"];
    self.location = [[theDict objectForKey:@"location"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"location"];
    self.blogURL = [NSURL smartURLFromString:[theDict objectForKey:@"blog"]];
    self.publicGistCount = [[theDict objectForKey:@"public_gists"] integerValue];
    self.privateGistCount = [[theDict objectForKey:@"private_gists"] integerValue];
    self.publicRepoCount = [[theDict objectForKey:@"public_repos"] integerValue];
    self.privateRepoCount = [[theDict objectForKey:@"total_private_repos"] integerValue];
    self.followersCount = [[theDict objectForKey:@"followers"] integerValue];
    self.followingCount = [[theDict objectForKey:@"following"] integerValue];
    self.isAuthenticated = [theDict objectForKey:@"plan"] ? YES : NO;
    self.gravatarURL = [NSURL URLWithString:[theDict objectForKey:@"avatar_url"]];
    self.htmlURL = [NSURL URLWithString:[theDict objectForKey:@"html_url"]];
}

#pragma mark Following

- (BOOL)isFollowing:(GHUser *)anUser {
	if (!following.isLoaded) [following loadData];
	return [following.users containsObject:anUser];
}

- (void)followUser:(GHUser *)theUser {
	[following.users addObject:theUser];
	[self setFollowing:YES forUser:theUser];
}

- (void)unfollowUser:(GHUser *)theUser {
	[following.users removeObject:theUser];
	[self setFollowing:NO forUser:theUser];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)theUser {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, theUser.login];
	ASIFormDataRequest *request = [GHResource apiRequestForPath:path];
	[request setDelegate:self];
	[request setRequestMethod:(follow ? @"PUT" : @"DELETE")];
	[request setDidFinishSelector:@selector(followToggleFinished:)];
	[request setDidFailSelector:@selector(followToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)followToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Follow toggle %@ finished: %@", [request url], [request responseString]);
	self.following.loadingStatus = GHResourceStatusNotProcessed;
    [self.following loadData];
}

- (void)followToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Follow toggle %@ failed: %@", [request url], [request error]);
	[iOctocat alert:@"Request error" with:@"Could not change following status"];
}

#pragma mark Stars

- (BOOL)isStarring:(GHRepository *)aRepository {
	if (!starredRepositories.isLoaded) [starredRepositories loadData];
	return [starredRepositories.repositories containsObject:aRepository];
}

- (void)starRepository:(GHRepository *)theRepository {
	[starredRepositories.repositories addObject:theRepository];
	[self setStarring:YES forRepository:theRepository];
}

- (void)unstarRepository:(GHRepository *)theRepository {
	[starredRepositories.repositories removeObject:theRepository];
	[self setStarring:NO forRepository:theRepository];
}

- (void)setStarring:(BOOL)watch forRepository:(GHRepository *)theRepository {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, theRepository.owner, theRepository.name];
	ASIFormDataRequest *request = [GHResource apiRequestForPath:path];
    [request setDelegate:self];
    [request setRequestMethod:(watch ? @"PUT": @"DELETE")];
	[request setDidFinishSelector:@selector(starToggleFinished:)];
	[request setDidFailSelector:@selector(starToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)starToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Star toggle %@ finished: %@", [request url], [request responseString]);
	self.starredRepositories.loadingStatus = GHResourceStatusNotProcessed;
    [self.starredRepositories loadData];
}

- (void)starToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Star toggle %@ failed: %@", [request url], [request error]);
	[iOctocat alert:@"Request error" with:@"Could not change starring status"];
}

#pragma mark Watching

- (BOOL)isWatching:(GHRepository *)aRepository {
	if (!watchedRepositories.isLoaded) [watchedRepositories loadData];
	return [watchedRepositories.repositories containsObject:aRepository];
}

- (void)watchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories addObject:theRepository];
	[self setWatching:YES forRepository:theRepository];
}

- (void)unwatchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories removeObject:theRepository];
	[self setWatching:NO forRepository:theRepository];
}

- (void)setWatching:(BOOL)watch forRepository:(GHRepository *)theRepository {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, theRepository.owner, theRepository.name];
	ASIFormDataRequest *request = [GHResource apiRequestForPath:path];
    [request setDelegate:self];
    [request setRequestMethod:(watch ? @"PUT": @"DELETE")];
	[request setDidFinishSelector:@selector(watchToggleFinished:)];
	[request setDidFailSelector:@selector(watchToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)watchToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Watch toggle %@ finished: %@", [request url], [request responseString]);
	self.watchedRepositories.loadingStatus = GHResourceStatusNotProcessed;
    [self.watchedRepositories loadData];
}

- (void)watchToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Watch toggle %@ failed: %@", [request url], [request error]);
	[iOctocat alert:@"Request error" with:@"Could not change watching status"];
}

#pragma mark Gists

- (BOOL)isStarringGist:(GHGist *)theGist {
	if (!starredGists.isLoaded) [starredGists loadData];
	return [starredGists.gists containsObject:theGist];
}

- (void)starGist:(GHGist *)theGist {
	[starredGists.gists addObject:theGist];
	[self setStarring:YES forGist:theGist];
}

- (void)unstarGist:(GHGist *)theGist {
	[starredGists.gists removeObject:theGist];
	[self setStarring:NO forGist:theGist];
}

- (void)setStarring:(BOOL)watch forGist:(GHGist *)theGist {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, theGist.gistId];
	ASIFormDataRequest *request = [GHResource apiRequestForPath:path];
    [request setDelegate:self];
    [request setRequestMethod:(watch ? @"PUT": @"DELETE")];
	[request setDidFinishSelector:@selector(gistStarToggleFinished:)];
	[request setDidFailSelector:@selector(gistStarToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)gistStarToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Gist star toggle %@ finished: %@", [request url], [request responseString]);
	self.starredGists.loadingStatus = GHResourceStatusNotProcessed;
    [self.starredGists loadData];
}

- (void)gistStarToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Gist star toggle %@ failed: %@", [request url], [request error]);
	[iOctocat alert:@"Request error" with:@"Could not change gist starring status"];
}

#pragma mark Gravatar

- (void)setGravatarURL:(NSURL *)theURL {
    [theURL retain];
	[gravatarURL release];
	gravatarURL = theURL;

	if (gravatarURL) [gravatarLoader loadURL:gravatarURL];
}

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[iOctocat cacheGravatar:gravatar forIdentifier:self.login];
}

@end
