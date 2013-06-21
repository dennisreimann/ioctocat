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
#import "IOCGravatarService.h"
#import "IOCAvatarCache.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHUser

- (id)initWithLogin:(NSString *)login {
	self = [self init];
	if (self) {
		self.login = login;
	}
	return self;
}

- (NSUInteger)hash {
	return [[self.login lowercaseString] hash];
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@", self.login];
    }
    return _htmlURL;
}

- (void)setLogin:(NSString *)login {
	_login = login;
	self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
	self.resourcePath = [NSString stringWithFormat:kUserFormat, self.login];
}

- (void)setGravatarURL:(NSURL *)url {
	_gravatarURL = url;
	if (self.gravatarURL && !self.gravatar) {
		[IOCGravatarService loadWithURL:self.gravatarURL success:^(UIImage *gravatar) {
            self.gravatar = gravatar;
        } failure:nil];
	}
}

- (void)setValues:(id)dict {
	NSString *login = [dict ioc_stringForKey:@"login"];
	if (![login ioc_isEmpty] && ![self.login isEqualToString:login]) {
		self.login = login;
	}
	// TODO: Remove email check once the API change is done.
	id email = [dict ioc_valueForKeyPath:@"email" defaultsTo:nil];
	if ([email isKindOfClass:NSDictionary.class]) {
		NSString *state = [email ioc_stringForKey:@"state"];
		email = [state isEqualToString:@"verified"] ? [dict ioc_stringForKey:@"email"] : nil;
	}
	self.name = [dict ioc_stringForKey:@"name"];
	self.email = email;
	self.company = [dict ioc_stringForKey:@"company"];
	self.location = [dict ioc_stringForKey:@"location"];
	self.blogURL = [dict ioc_URLForKey:@"blog"];
	self.htmlURL = [dict ioc_URLForKey:@"html_url"];
	self.gravatarURL = [dict ioc_URLForKey:@"avatar_url"];
	self.publicGistCount = [dict ioc_integerForKey:@"public_gists"];
	self.privateGistCount = [dict ioc_integerForKey:@"private_gists"];
	self.publicRepoCount = [dict ioc_integerForKey:@"public_repos"];
	self.privateRepoCount = [dict ioc_integerForKey:@"total_private_repos"];
	self.followersCount = [dict ioc_integerForKey:@"followers"];
	self.followingCount = [dict ioc_integerForKey:@"following"];
}

#pragma mark Associations

- (GHOrganizations *)organizations {
	if (!_organizations) {
		NSString *organizationsPath = [NSString stringWithFormat:kUserOrganizationsFormat, self.login];
		_organizations = [[GHOrganizations alloc] initWithPath:organizationsPath];
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

- (void)checkUserFollowing:(GHUser *)user usingBlock:(void (^)(BOOL isStarring))block {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
		if (block) block(YES);
	} failure:^(GHResource *instance, NSError *error) {
		if (block) block(NO);
	}];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kUserFollowFormat, user.login];
	NSString *method = follow ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:NULL success:^(GHResource *instance, id data) {
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

- (void)checkGistStarring:(GHGist *)gist usingBlock:(void (^)(BOOL isStarring))block {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
		if (block) block(YES);
	} failure:^(GHResource *instance, NSError *error) {
		if (block) block(NO);
	}];
}

- (void)setStarring:(BOOL)starred forGist:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kGistStarFormat, gist.gistId];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:NULL success:^(GHResource *instance, id data) {
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

- (void)checkRepositoryStarring:(GHRepository *)repo usingBlock:(void (^)(BOOL isStarring))block {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
		if (block) block(YES);
	} failure:^(GHResource *instance, NSError *error) {
		if (block) block(NO);
	}];
}

- (void)setStarring:(BOOL)starred forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoStarFormat, repo.owner, repo.name];
	NSString *method = starred ? kRequestMethodPut : kRequestMethodDelete;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:nil path:path method:method start:NULL success:^(GHResource *instance, id data) {
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

- (void)checkRepositoryWatching:(GHRepository *)repo usingBlock:(void (^)(BOOL isStarring))block {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
		if (block) block(YES);
	} failure:^(GHResource *instance, NSError *error) {
		if (block) block(NO);
	}];
}

- (void)setWatching:(BOOL)watched forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoWatchFormat, repo.owner, repo.name];
	NSString *method = watched ? kRequestMethodPut : kRequestMethodDelete;
	NSDictionary *params = watched ? @{@"subscribed": @"true"} : nil;
	GHResource *resource = [[GHResource alloc] initWithPath:path];
	[resource saveWithParams:params path:path method:method start:NULL success:^(GHResource *instance, id data) {
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

@end