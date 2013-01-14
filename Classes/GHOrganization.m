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
		self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
	}
	return self;
}

- (NSUInteger)hash {
	NSString *hashValue = [self.login lowercaseString];
	return [hashValue hash];
}

- (int)compareByName:(GHOrganization *)otherOrg {
	return [self.login localizedCaseInsensitiveCompare:otherOrg.login];
}

- (void)setLogin:(NSString *)login {
	_login = login;

	NSString *repositoriesPath = [NSString stringWithFormat:kOrganizationRepositoriesFormat, self.login];
	NSString *membersPath = [NSString stringWithFormat:kOrganizationMembersFormat, self.login];
	NSString *eventsPath = [NSString stringWithFormat:kOrganizationEventsFormat, self.login];

	self.resourcePath = [NSString stringWithFormat:kOrganizationFormat, self.login];
	self.repositories = [[GHRepositories alloc] initWithPath:repositoriesPath];
	self.publicMembers = [[GHUsers alloc] initWithPath:membersPath];
	self.events = [[GHEvents alloc] initWithPath:eventsPath];
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
	if (![login isEmpty] && ![self.login isEqualToString:login]) self.login = login;
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