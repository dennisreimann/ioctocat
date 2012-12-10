#import "GHUser.h"
#import "GHUsers.h"
#import "GHOrganizations.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHResource.h"
#import "IOCAvatarLoader.h"
#import "IOCAvatarCache.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHUser ()
@property(nonatomic,strong)IOCAvatarLoader *gravatarLoader;
@end


@implementation GHUser

- (id)initWithLogin:(NSString *)theLogin {
	self = [self init];
	if (self) {
		self.login = theLogin;
		self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
		self.isAuthenticated = NO;
	}
	return self;
}

- (NSUInteger)hash {
	NSString *hashValue = [self.login lowercaseString];
	return [hashValue hash];
}

- (int)compareByName:(GHUser *)theOtherUser {
	return [self.login localizedCaseInsensitiveCompare:theOtherUser.login];
}

- (void)setLogin:(NSString *)theLogin {
	_login = theLogin;

	NSString *repositoriesPath  = [NSString stringWithFormat:kUserReposFormat, self.login];
	NSString *organizationsPath = [NSString stringWithFormat:kUserOrganizationsFormat, self.login];
	NSString *watchedReposPath  = [NSString stringWithFormat:kUserWatchedReposFormat, self.login];
	NSString *starredReposPath  = [NSString stringWithFormat:kUserStarredReposFormat, self.login];
	NSString *followingPath     = [NSString stringWithFormat:kUserFollowingFormat, self.login];
	NSString *followersPath     = [NSString stringWithFormat:kUserFollowersFormat, self.login];
	NSString *eventsPath        = [NSString stringWithFormat:kUserEventsFormat, self.login];
	NSString *gistsPath         = [NSString stringWithFormat:kUserGistsFormat, self.login];
	NSString *starredGistsPath  = [NSString stringWithFormat:kStarredGistsFormat];

	self.resourcePath = [NSString stringWithFormat:kUserFormat, self.login];
	self.organizations = [[GHOrganizations alloc] initWithUser:self andPath:organizationsPath];
	self.repositories = [[GHRepositories alloc] initWithPath:repositoriesPath];
	self.starredRepositories = [[GHRepositories alloc] initWithPath:starredReposPath];
	self.watchedRepositories = [[GHRepositories alloc] initWithPath:watchedReposPath];
	self.starredGists = [[GHGists alloc] initWithPath:starredGistsPath];
	self.following = [[GHUsers alloc] initWithPath:followingPath];
	self.followers = [[GHUsers alloc] initWithPath:followersPath];
	self.events = [[GHEvents alloc] initWithPath:eventsPath];
	self.gists = [[GHGists alloc] initWithPath:gistsPath];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	NSString *theLogin = [theDict valueForKey:@"login" defaultsTo:@""];
	if (![theLogin isEmpty] && ![self.login isEqualToString:theLogin]) self.login = [theDict objectForKey:@"login"];
	
	self.name = [theDict valueForKey:@"name" defaultsTo:@""];
	self.email = [theDict valueForKey:@"email" defaultsTo:@""];
	self.company = [theDict valueForKey:@"company" defaultsTo:@""];
	self.location = [theDict valueForKey:@"location" defaultsTo:@""];
	self.blogURL = [NSURL smartURLFromString:[theDict valueForKey:@"blog" defaultsTo:@""]];
	self.htmlURL = [NSURL smartURLFromString:[theDict valueForKey:@"html_url" defaultsTo:@""]];
	self.gravatarURL = [NSURL smartURLFromString:[theDict valueForKey:@"avatar_url" defaultsTo:@""]];
	self.publicGistCount = [[theDict objectForKey:@"public_gists"] integerValue];
	self.privateGistCount = [[theDict objectForKey:@"private_gists"] integerValue];
	self.publicRepoCount = [[theDict objectForKey:@"public_repos"] integerValue];
	self.privateRepoCount = [[theDict objectForKey:@"total_private_repos"] integerValue];
	self.followersCount = [[theDict objectForKey:@"followers"] integerValue];
	self.followingCount = [[theDict objectForKey:@"following"] integerValue];
	self.isAuthenticated = [theDict objectForKey:@"plan"] ? YES : NO;
}

#pragma mark Following

- (BOOL)isFollowing:(GHUser *)anUser {
	if (!self.following.isLoaded) [self.following loadData];
	return [self.following.users containsObject:anUser];
}

- (void)followUser:(GHUser *)theUser {
	[self.following.users addObject:theUser];
	[self setFollowing:YES forUser:theUser];
}

- (void)unfollowUser:(GHUser *)theUser {
	[self.following.users removeObject:theUser];
	[self setFollowing:NO forUser:theUser];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)theUser {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, theUser.login];
	[self saveValues:nil withPath:path andMethod:(follow ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Stars

- (BOOL)isStarring:(GHRepository *)aRepository {
	if (!self.starredRepositories.isLoaded) [self.starredRepositories loadData];
	return [self.starredRepositories.repositories containsObject:aRepository];
}

- (void)starRepository:(GHRepository *)theRepository {
	[self.starredRepositories.repositories addObject:theRepository];
	[self setStarring:YES forRepository:theRepository];
}

- (void)unstarRepository:(GHRepository *)theRepository {
	[self.starredRepositories.repositories removeObject:theRepository];
	[self setStarring:NO forRepository:theRepository];
}

- (void)setStarring:(BOOL)watch forRepository:(GHRepository *)theRepository {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, theRepository.owner, theRepository.name];
	[self saveValues:nil withPath:path andMethod:(watch ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Watching

- (BOOL)isWatching:(GHRepository *)aRepository {
	if (!self.watchedRepositories.isLoaded) [self.watchedRepositories loadData];
	return [self.watchedRepositories.repositories containsObject:aRepository];
}

- (void)watchRepository:(GHRepository *)theRepository {
	[self.watchedRepositories.repositories addObject:theRepository];
	[self setWatching:YES forRepository:theRepository];
}

- (void)unwatchRepository:(GHRepository *)theRepository {
	[self.watchedRepositories.repositories removeObject:theRepository];
	[self setWatching:NO forRepository:theRepository];
}

- (void)setWatching:(BOOL)watch forRepository:(GHRepository *)theRepository {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, theRepository.owner, theRepository.name];
	id values = watch ? [NSDictionary dictionaryWithObject:@"true" forKey:@"subscribed"] : nil;
	[self saveValues:values withPath:path andMethod:(watch ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Gists

- (BOOL)isStarringGist:(GHGist *)theGist {
	if (!self.starredGists.isLoaded) [self.starredGists loadData];
	return [self.starredGists.gists containsObject:theGist];
}

- (void)starGist:(GHGist *)theGist {
	[self.starredGists.gists addObject:theGist];
	[self setStarring:YES forGist:theGist];
}

- (void)unstarGist:(GHGist *)theGist {
	[self.starredGists.gists removeObject:theGist];
	[self setStarring:NO forGist:theGist];
}

- (void)setStarring:(BOOL)starred forGist:(GHGist *)theGist {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, theGist.gistId];
	[self saveValues:nil withPath:path andMethod:(starred ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Gravatar

- (void)setGravatarURL:(NSURL *)theURL {
	_gravatarURL = theURL;

	if (self.gravatarURL && !self.gravatar) {
		self.gravatarLoader = [IOCAvatarLoader loaderWithTarget:self andHandle:@selector(loadedGravatar:)];
		[self.gravatarLoader loadURL:self.gravatarURL];
	}
}

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
}

@end