#import "GHUser.h"
#import "GHUsers.h"
#import "GHOrganizations.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHResource.h"
#import "GHNotifications.h"
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

- (void)checkUserFollowing:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	NSString *method = follow ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method success:^(GHResource *instance, id data) {
		if (follow) {
			[self.following addObject:user];
		} else {
			[self.following removeObject:user];
		}
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Stars

- (void)checkRepositoryStarring:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setStarring:(BOOL)starred forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method success:^(GHResource *instance, id data) {
		if (starred) {
			[self.starredRepositories addObject:repo];
		} else {
			[self.starredRepositories removeObject:repo];
		}
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Watching

- (void)checkRepositoryWatching:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil path:path method:kRequestMethodGet success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setWatching:(BOOL)watched forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	NSString *method = watched ? kRequestMethodPut : kRequestMethodDelete;
	NSDictionary *params = watched ? @{@"subscribed": @"true"} : nil;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:params path:path method:method success:^(GHResource *instance, id data) {
		if (watched) {
			[self.watchedRepositories addObject:repo];
		} else {
			[self.watchedRepositories removeObject:repo];
		}
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Gists

- (void)checkGistStarring:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil path:path method:kRequestMethodGet success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setStarring:(BOOL)starred forGist:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method success:^(GHResource *instance, id data) {
		if (starred) {
			[self.starredGists addObject:gist];
		} else {
			[self.starredGists removeObject:gist];
		}
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];

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