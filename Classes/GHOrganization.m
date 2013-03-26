#import "GHOrganization.h"
#import "GHAccount.h"
#import "GHEvents.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCGravatarService.h"
#import "IOCAvatarCache.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHOrganization

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

- (int)compareByName:(GHOrganization *)otherOrg {
	return [self.login localizedCaseInsensitiveCompare:otherOrg.login];
}

- (void)setLogin:(NSString *)login {
	_login = login;
	self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
	self.resourcePath = [NSString stringWithFormat:kOrganizationFormat, self.login];
}

- (void)setGravatarURL:(NSURL *)url {
	_gravatarURL = url;
	if (self.gravatarURL && !self.gravatar) {
        [IOCGravatarService loadWithURL:self.gravatarURL success:^(UIImage *gravatar) {
            self.gravatar = gravatar;
            [IOCAvatarCache cacheGravatar:gravatar forIdentifier:self.login];
        } failure:nil];
	}
}

- (void)setValues:(id)dict {
	NSDictionary *resource = [dict safeDictForKey:@"organization"] ? [dict safeDictForKey:@"organization"] : dict;
	NSString *login = [resource safeStringForKey:@"login"];
	// TODO: Remove email check once the API change is done.
	id email = [dict valueForKeyPath:@"email" defaultsTo:nil];
	if ([email isKindOfClass:NSDictionary.class]) {
		NSString *state = [email safeStringForKey:@"state"];
		email = [state isEqualToString:@"verified"] ? [dict safeStringForKey:@"email"] : nil;
	}
	// Check the values before setting them, because the organizations list does
	// not include all fields. This unsets some fields when reloading the orgs,
	// after an org has already been fully loaded (because the orgs are cached).
	NSString *name = [resource safeStringOrNilForKey:@"name"];
	NSString *location = [resource safeStringOrNilForKey:@"location"];
	NSURL *blogURL = [resource safeURLForKey:@"blog"];
	NSURL *htmlURL = [resource safeURLForKey:@"html_url"];
	NSURL *gravatarURL = [resource safeURLForKey:@"avatar_url"];
	NSInteger publicRepoCount = [resource safeIntegerForKey:@"public_repos"];
	NSInteger privateRepoCount = [resource safeIntegerForKey:@"total_private_repos"];
	if (!login.isEmpty && ![self.login isEqualToString:login]) self.login = login;
	if (name) self.name = name;
	if (email) self.email = email;
	if (blogURL) self.location = location;
	if (location) self.blogURL = blogURL;
	if (htmlURL) self.htmlURL = htmlURL;
	if (gravatarURL) self.gravatarURL = gravatarURL;
	if (publicRepoCount) self.publicRepoCount = publicRepoCount;
	if (privateRepoCount) self.privateRepoCount = privateRepoCount;
}

#pragma mark Associations

- (GHRepositories *)repositories {
	if (!_repositories) {
		NSString *reposPath = [NSString stringWithFormat:kOrganizationRepositoriesFormat, self.login];
		_repositories = [[GHRepositories alloc] initWithPath:reposPath];
	}
	return _repositories;
}

- (GHUsers *)publicMembers {
	if (!_publicMembers) {
		NSString *membersPath = [NSString stringWithFormat:kOrganizationMembersFormat, self.login];
		_publicMembers = [[GHUsers alloc] initWithPath:membersPath];
	}
	return _publicMembers;
}

- (GHEvents *)events {
	if (!_events) {
		NSString *eventsPath = [NSString stringWithFormat:kOrganizationEventsFormat, self.login];
		_events = [[GHEvents alloc] initWithPath:eventsPath];
	}
	return _events;
}

@end