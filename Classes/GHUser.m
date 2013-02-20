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
		self.isAuthenticated = NO;
	}
	return self;
}

- (NSUInteger)hash {
	return [[self.login lowercaseString] hash];
}

- (int)compareByName:(GHUser *)otherUser {
	return [self.login localizedCaseInsensitiveCompare:otherUser.login];
}

- (void)setLogin:(NSString *)login {
	_login = login;
	self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
	self.resourcePath = [NSString stringWithFormat:kUserFormat, self.login];
}

- (void)setGravatarURL:(NSURL *)url {
	_gravatarURL = url;
	if (self.gravatarURL && !self.gravatar) {
		self.gravatarLoader = [IOCAvatarLoader loaderWithTarget:self andHandle:@selector(setGravatar:)];
		[self.gravatarLoader loadURL:self.gravatarURL];
	}
}

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKey:@"login"];
	if (!login.isEmpty && ![self.login isEqualToString:login]) {
		self.login = login;
	}
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

#pragma mark Associations

- (GHOrganizations *)organizations {
	if (!_organizations) {
		NSString *organizationsPath = [NSString stringWithFormat:kUserOrganizationsFormat, self.login];
		_organizations = [[GHOrganizations alloc] initWithUser:self andPath:organizationsPath];
	}
	return _organizations;
}

- (GHRepositories *)repositories {
	if (!_repositories) {
		NSString *reposPath = [NSString stringWithFormat:kUserReposFormat, self.login];
		_repositories = [[GHRepositories alloc] initWithPath:reposPath];
	}
	return _repositories;
}

- (GHRepositories *)starredRepositories {
	if (!_starredRepositories) {
		NSString *starredReposPath = [NSString stringWithFormat:kUserStarredReposFormat, self.login];
		_starredRepositories = [[GHRepositories alloc] initWithPath:starredReposPath];
	}
	return _starredRepositories;
}

- (GHRepositories *)watchedRepositories {
	if (!_watchedRepositories) {
		NSString *watchedReposPath = [NSString stringWithFormat:kUserWatchedReposFormat, self.login];
		_watchedRepositories = [[GHRepositories alloc] initWithPath:watchedReposPath];
	}
	return _watchedRepositories;
}

- (GHGists *)gists {
	if (!_gists) {
		NSString *gistsPath = [NSString stringWithFormat:kUserGistsFormat, self.login];
		_gists = [[GHGists alloc] initWithPath:gistsPath];
	}
	return _gists;
}

- (GHGists *)starredGists {
	if (!_starredGists) {
		NSString *starredGistsPath = [NSString stringWithFormat:kStarredGistsFormat];
		_starredGists = [[GHGists alloc] initWithPath:starredGistsPath];
	}
	return _starredGists;
}

- (GHUsers *)following {
	if (!_following) {
		NSString *followingPath = [NSString stringWithFormat:kUserFollowingFormat, self.login];
		_following = [[GHUsers alloc] initWithPath:followingPath];
	}
	return _following;
}

- (GHUsers *)followers {
	if (!_followers) {
		NSString *followersPath = [NSString stringWithFormat:kUserFollowersFormat, self.login];
		_followers = [[GHUsers alloc] initWithPath:followersPath];
	}
	return _followers;
}

- (GHEvents *)events {
	if (!_events) {
		NSString *eventsPath = [NSString stringWithFormat:kUserEventsFormat, self.login];
		_events = [[GHEvents alloc] initWithPath:eventsPath];
	}
	return _events;
}

- (GHEvents *)receivedEvents {
	if (!_receivedEvents) {
		NSString *receivedEventsPath = [NSString stringWithFormat:kUserReceivedEventsFormat, self.login];
		_receivedEvents = [[GHEvents alloc] initWithPath:receivedEventsPath];
	}
	return _receivedEvents;
}

#pragma mark User Following

- (void)checkUserFollowing:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	NSString *method = follow ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:nil success:^(GHResource *instance, id data) {
		if (follow) {
			[self.following addObject:user];
		} else {
			[self.following removeObject:user];
		}
		[self.following markAsChanged];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Gist Stars

- (void)checkGistStarring:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil path:path method:kRequestMethodGet start:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setStarring:(BOOL)starred forGist:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:nil success:^(GHResource *instance, id data) {
		if (starred) {
			[self.starredGists addObject:gist];
		} else {
			[self.starredGists removeObject:gist];
		}
		[self.starredGists markAsChanged];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Repo Stars

- (void)checkRepositoryStarring:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)setStarring:(BOOL)starred forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:nil success:^(GHResource *instance, id data) {
		if (starred) {
			[self.starredRepositories addObject:repo];
		} else {
			[self.starredRepositories removeObject:repo];
		}
		[self.starredRepositories markAsChanged];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Repo Watching

- (void)checkRepositoryWatching:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil path:path method:kRequestMethodGet start:nil success:^(GHResource *instance, id data) {
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
	[resource saveWithParams:params path:path method:method start:nil success:^(GHResource *instance, id data) {
		if (watched) {
			[self.watchedRepositories addObject:repo];
		} else {
			[self.watchedRepositories removeObject:repo];
		}
		[self.watchedRepositories markAsChanged];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

#pragma mark Repo Assignment

- (void)checkRepositoryAssignment:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoAssigneeFormat, repo.owner, repo.name, self.login];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil path:path method:kRequestMethodGet start:nil success:^(GHResource *instance, id data) {
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end