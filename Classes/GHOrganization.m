#import "GHOrganization.h"
#import "GHAccount.h"
#import "GHEvents.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCAvatarLoader.h"
#import "IOCAvatarCache.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHOrganization ()
@property(nonatomic,strong)IOCAvatarLoader *gravatarLoader;
@end


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
		self.gravatarLoader = [IOCAvatarLoader loaderWithTarget:self andHandle:@selector(setGravatar:)];
		[self.gravatarLoader loadURL:self.gravatarURL];
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
	if (!login.isEmpty && ![self.login isEqualToString:login]) self.login = login;
	self.name = [resource safeStringForKey:@"name"];
	self.email = email;
	self.company = [resource safeStringForKey:@"company"];
	self.location = [resource safeStringForKey:@"location"];
	self.blogURL = [resource safeURLForKey:@"blog"];
	self.htmlURL = [resource safeURLForKey:@"html_url"];
	self.gravatarURL = [resource safeURLForKey:@"avatar_url"];
	self.followersCount = [resource safeIntegerForKey:@"followers"];
	self.followingCount = [resource safeIntegerForKey:@"following"];
	self.publicGistCount = [resource safeIntegerForKey:@"public_gists"];
	self.privateGistCount = [resource safeIntegerForKey:@"private_gists"];
	self.publicRepoCount = [resource safeIntegerForKey:@"public_repos"];
	self.privateRepoCount = [resource safeIntegerForKey:@"total_private_repos"];
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