#import "GHOrganization.h"
#import "GHAccount.h"
#import "GHEvents.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCAvatarLoader.h"
#import "IOCAvatarCache.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHOrganization ()
@property(nonatomic,strong)IOCAvatarLoader *gravatarLoader;
@end


@implementation GHOrganization

- (id)initWithLogin:(NSString *)theLogin {
	self = [self init];
	if (self) {
		self.login = theLogin;
		self.gravatar = [IOCAvatarCache cachedGravatarForIdentifier:self.login];
	}
	return self;
}

- (NSUInteger)hash {
	NSString *hashValue = [self.login lowercaseString];
	return [hashValue hash];
}

- (int)compareByName:(GHOrganization *)theOtherOrg {
	return [self.login localizedCaseInsensitiveCompare:theOtherOrg.login];
}

- (void)setLogin:(NSString *)theLogin {
	_login = theLogin;

	NSString *repositoriesPath = [NSString stringWithFormat:kOrganizationRepositoriesFormat, self.login];
	NSString *membersPath = [NSString stringWithFormat:kOrganizationMembersFormat, self.login];
	NSString *eventsPath = [NSString stringWithFormat:kOrganizationEventsFormat, self.login];

	self.resourcePath = [NSString stringWithFormat:kOrganizationFormat, self.login];
	self.repositories = [[GHRepositories alloc] initWithPath:repositoriesPath];
	self.publicMembers = [[GHUsers alloc] initWithPath:membersPath];
	self.events = [[GHEvents alloc] initWithPath:eventsPath];
}

- (void)setValues:(id)theDict {
	NSDictionary *resource = theDict[@"organization"] ? theDict[@"organization"] : theDict;
	NSString *login = [resource valueForKey:@"login" defaultsTo:nil];
	// TODO: Remove email check once the API change is done.
	id email = [resource valueForKeyPath:@"email" defaultsTo:nil];
	if ([email isKindOfClass:[NSDictionary class]])	{
		email = [[email valueForKey:@"state"] isEqualToString:@"verified"] ? [resource valueForKey:@"email"] : @"";
	}
	if (![login isEmpty] && ![self.login isEqualToString:login]) self.login = login;
	self.name = [resource valueForKey:@"name" defaultsTo:@""];
	self.email = email;
	self.company = [resource valueForKey:@"company" defaultsTo:@""];
	self.location = [resource valueForKey:@"location" defaultsTo:@""];
	self.blogURL = [NSURL smartURLFromString:[resource valueForKey:@"blog" defaultsTo:@""]];
	self.followersCount = [[resource valueForKey:@"followers" defaultsTo:nil] integerValue];
	self.followingCount = [[resource valueForKey:@"following" defaultsTo:nil] integerValue];
	self.publicGistCount = [[resource valueForKey:@"public_gists" defaultsTo:nil] integerValue];
	self.privateGistCount = [[resource valueForKey:@"private_gists" defaultsTo:nil] integerValue];
	self.publicRepoCount = [[resource valueForKey:@"public_repos" defaultsTo:nil] integerValue];
	self.privateRepoCount = [[resource valueForKey:@"total_private_repos" defaultsTo:nil] integerValue];
	self.gravatarURL = [NSURL URLWithString:theDict[@"avatar_url"]];
	self.htmlURL = [NSURL URLWithString:theDict[@"html_url"]];
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