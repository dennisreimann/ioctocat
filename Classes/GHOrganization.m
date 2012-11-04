#import "GHOrganization.h"
#import "GHAccount.h"
#import "GHFeed.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GravatarLoader.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"


@implementation GHOrganization

@synthesize name;
@synthesize login;
@synthesize email;
@synthesize company;
@synthesize blogURL;
@synthesize htmlURL;
@synthesize location;
@synthesize gravatarURL;
@synthesize gravatar;
@synthesize publicMembers;
@synthesize repositories;
@synthesize recentActivity;
@synthesize followersCount;
@synthesize followingCount;
@synthesize publicGistCount;
@synthesize privateGistCount;
@synthesize publicRepoCount;
@synthesize privateRepoCount;

+ (id)organizationWithLogin:(NSString *)theLogin {
	return [[[[self class] alloc] initWithLogin:theLogin] autorelease];
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [iOctocat cachedGravatarForIdentifier:self.login];
    gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[login release], login = nil;
	[email release], email = nil;
	[company release], company = nil;
	[blogURL release], blogURL = nil;
	[htmlURL release], htmlURL = nil;
	[location release], location = nil;
    [gravatarLoader release], gravatarLoader = nil;
	[gravatarURL release], gravatarURL = nil;
	[gravatar release], gravatar = nil;
	[publicMembers release], publicMembers = nil;
	[repositories release], repositories = nil;
	[recentActivity release], recentActivity = nil;
    [super dealloc];
}

- (NSUInteger)hash {
	NSString *hashValue = [login lowercaseString];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHOrganization login:'%@' status:'%d' name:'%@'>", login, loadingStatus, name];
}

- (int)compareByName:(GHOrganization *)theOtherOrg {
    return [login localizedCaseInsensitiveCompare:[theOtherOrg login]];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;

    GHAccount *account = [[iOctocat sharedInstance] currentAccount];
    NSString *activityFeedPath = [NSString stringWithFormat:kOrganizationFeedFormat, login, account.login];
	NSString *repositoriesPath = [NSString stringWithFormat:kOrganizationRepositoriesFormat, login];
	NSString *membersPath = [NSString stringWithFormat:kOrganizationMembersFormat, login];

    self.resourcePath = [NSString stringWithFormat:kOrganizationFormat, login];
	self.repositories = [GHRepositories repositoriesWithPath:repositoriesPath];
	self.publicMembers = [GHUsers usersWithPath:membersPath];
    self.recentActivity = [GHFeed resourceWithPath:activityFeedPath];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *resource = [theDict objectForKey:@"organization"] ? [theDict objectForKey:@"organization"] : theDict;

    if (![login isEqualToString:[resource objectForKey:@"login"]]) self.login = [resource objectForKey:@"login"];
    self.email = [[resource objectForKey:@"email"] isKindOfClass:[NSNull class]] ? nil : [resource objectForKey:@"email"];
    self.name = [[resource objectForKey:@"name"] isKindOfClass:[NSNull class]] ? nil : [resource objectForKey:@"name"];
    self.company = [[resource objectForKey:@"company"] isKindOfClass:[NSNull class]] ? nil : [resource objectForKey:@"company"];
    self.location = [[resource objectForKey:@"location"] isKindOfClass:[NSNull class]] ? nil : [resource objectForKey:@"location"];
    self.blogURL = [[resource objectForKey:@"blog"] isKindOfClass:[NSNull class]] ? nil : [NSURL smartURLFromString:[resource objectForKey:@"blog"]];
    self.followersCount = [[resource objectForKey:@"followers"] integerValue];
    self.followingCount = [[resource objectForKey:@"following"] integerValue];
    self.publicGistCount = [[resource objectForKey:@"public_gists"] integerValue];
    self.privateGistCount = [[resource objectForKey:@"private_gists"] integerValue];
    self.publicRepoCount = [[resource objectForKey:@"public_repos"] integerValue];
    self.privateRepoCount = [[resource objectForKey:@"total_private_repos"] integerValue];
    self.gravatarURL = [NSURL URLWithString:[theDict objectForKey:@"avatar_url"]];
    self.htmlURL = [NSURL URLWithString:[theDict objectForKey:@"html_url"]];
}

#pragma mark Gravatar

- (void)setGravatarURL:(NSURL *)theURL {
    [theURL retain];
	[gravatarURL release];
	gravatarURL = theURL;

	if (gravatarURL) {
        [gravatarLoader loadURL:gravatarURL];
    }
}

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[iOctocat cacheGravatar:gravatar forIdentifier:self.login];
}

@end
