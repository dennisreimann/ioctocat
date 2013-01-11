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
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHUser ()
@property(nonatomic,strong)IOCAvatarLoader *gravatarLoader;
@end


@implementation GHUser

- (id)initWithLogin:(NSString *)login {
	self = [self init];
	if (self) {
		self.login = login;
		self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
		self.isAuthenticated = NO;
	}
	return self;
}

- (NSUInteger)hash {
	NSString *hashValue = [self.login lowercaseString];
	return [hashValue hash];
}

- (int)compareByName:(GHUser *)otherUser {
	return [self.login localizedCaseInsensitiveCompare:otherUser.login];
}

- (void)setLogin:(NSString *)login {
	_login = login;

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

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKey:@"login"];
	if (![login isEmpty] && ![self.login isEqualToString:login]) self.login = [dict safeStringForKey:@"login"];
	// TODO: Remove email check once the API change is done.
	id email = [dict valueForKeyPath:@"email" defaultsTo:nil];
	if ([email isKindOfClass:NSDictionary.class]) {
		NSString *state = [email safeStringForKey:@"state"];
		email = [state isEqualToString:@"verified"] ? [dict safeStringForKey:@"email"] : nil;
	}
	self.name = [dict safeStringForKey:@"name"];
	self.email = email;
	self.company = [dict safeStringForKey:@"company"];
	self.location = [dict safeStringForKey:@"location"];
	self.blogURL = [dict safeURLForKey:@"blog"];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	self.gravatarURL = [dict safeURLForKey:@"avatar_url"];
	self.publicGistCount = [dict safeIntegerForKey:@"public_gists"];
	self.privateGistCount = [dict safeIntegerForKey:@"private_gists"];
	self.publicRepoCount = [dict safeIntegerForKey:@"public_repos"];
	self.privateRepoCount = [dict safeIntegerForKey:@"total_private_repos"];
	self.followersCount = [dict safeIntegerForKey:@"followers"];
	self.followingCount = [dict safeIntegerForKey:@"following"];
	self.isAuthenticated = [dict safeDictForKey:@"plan"] ? YES : NO;
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

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)user {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
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

- (void)setStarring:(BOOL)starred forGist:(GHGist *)gist {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	[self saveValues:nil withPath:path andMethod:(starred ? kRequestMethodPut : kRequestMethodDelete) useResult:nil];
}

#pragma mark Gravatar

- (void)setGravatarURL:(NSURL *)url {
	_gravatarURL = url;

	if (self.gravatarURL && !self.gravatar) {
		self.gravatarLoader = [IOCAvatarLoader loaderWithTarget:self andHandle:@selector(loadedGravatar:)];
		[self.gravatarLoader loadURL:self.gravatarURL];
	}
}

- (void)loadedGravatar:(UIImage *)image {
	self.gravatar = image;
}

@end