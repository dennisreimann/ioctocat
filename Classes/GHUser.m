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
	NSString *login = [theDict valueForKey:@"login" defaultsTo:@""];
	if (![login isEmpty] && ![self.login isEqualToString:login]) self.login = theDict[@"login"];
	// TODO: Remove email check once the API change is done.
	id email = [theDict valueForKeyPath:@"email" defaultsTo:@""];
	if ([email isKindOfClass:[NSDictionary class]])	{
		email = [[email valueForKey:@"state"] isEqualToString:@"verified"] ? [theDict valueForKey:@"email"] : @"";
	}
	self.name = [theDict valueForKey:@"name" defaultsTo:@""];
	self.email = email;
	self.company = [theDict valueForKey:@"company" defaultsTo:@""];
	self.location = [theDict valueForKey:@"location" defaultsTo:@""];
	self.blogURL = [NSURL smartURLFromString:[theDict valueForKey:@"blog" defaultsTo:@""]];
	self.htmlURL = [NSURL smartURLFromString:[theDict valueForKey:@"html_url" defaultsTo:@""]];
	self.gravatarURL = [NSURL smartURLFromString:[theDict valueForKey:@"avatar_url" defaultsTo:@""]];
	self.publicGistCount = [theDict[@"public_gists"] integerValue];
	self.privateGistCount = [theDict[@"private_gists"] integerValue];
	self.publicRepoCount = [theDict[@"public_repos"] integerValue];
	self.privateRepoCount = [theDict[@"total_private_repos"] integerValue];
	self.followersCount = [theDict[@"followers"] integerValue];
	self.followingCount = [theDict[@"following"] integerValue];
	self.isAuthenticated = theDict[@"plan"] ? YES : NO;
}

#pragma mark Following

- (BOOL)isFollowing:(GHUser *)user {
	if (!self.following.isLoaded) [self.following loadData];
	return [self.following containsObject:user];
}

- (void)followUser:(GHUser *)user {
	[self.following addObject:user];
	[self setFollowing:YES forUser:user];
}

- (void)unfollowUser:(GHUser *)user {
	[self.following removeObject:user];
	[self setFollowing:NO forUser:user];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)theUser {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, theUser.login];
	[self saveValues:nil withPath:path andMethod:(follow ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Stars

- (BOOL)isStarring:(GHRepository *)repo {
	if (!self.starredRepositories.isLoaded) [self.starredRepositories loadData];
	return [self.starredRepositories containsObject:repo];
}

- (void)starRepository:(GHRepository *)repo {
	[self.starredRepositories addObject:repo];
	[self setStarring:YES forRepository:repo];
}

- (void)unstarRepository:(GHRepository *)repo {
	[self.starredRepositories removeObject:repo];
	[self setStarring:NO forRepository:repo];
}

- (void)setStarring:(BOOL)watch forRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	[self saveValues:nil withPath:path andMethod:(watch ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Watching

- (BOOL)isWatching:(GHRepository *)repo {
	if (!self.watchedRepositories.isLoaded) [self.watchedRepositories loadData];
	return [self.watchedRepositories containsObject:repo];
}

- (void)watchRepository:(GHRepository *)repo {
	[self.watchedRepositories addObject:repo];
	[self setWatching:YES forRepository:repo];
}

- (void)unwatchRepository:(GHRepository *)repo {
	[self.watchedRepositories removeObject:repo];
	[self setWatching:NO forRepository:repo];
}

- (void)setWatching:(BOOL)watch forRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	id values = watch ? @{@"subscribed": @"true"} : nil;
	[self saveValues:values withPath:path andMethod:(watch ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Gists

- (BOOL)isStarringGist:(GHGist *)gist {
	if (!self.starredGists.isLoaded) [self.starredGists loadData];
	return [self.starredGists containsObject:gist];
}

- (void)starGist:(GHGist *)gist {
	[self.starredGists addObject:gist];
	[self setStarring:YES forGist:gist];
}

- (void)unstarGist:(GHGist *)gist {
	[self.starredGists removeObject:gist];
	[self setStarring:NO forGist:gist];
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