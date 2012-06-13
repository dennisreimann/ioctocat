#import "GHOrganization.h"
#import "GHFeed.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GravatarLoader.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"


@implementation GHOrganization

@synthesize name;
@synthesize login;
@synthesize email;
@synthesize company;
@synthesize blogURL;
@synthesize location;
@synthesize gravatarURL;
@synthesize gravatar;
@synthesize publicMembers;
@synthesize publicRepositories;
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
	self.gravatar = [UIImage imageWithContentsOfFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login]];
    gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[login release], login = nil;
	[email release], email = nil;
	[company release], company = nil;
	[blogURL release], blogURL = nil;
	[location release], location = nil;
    [gravatarLoader release], gravatarLoader = nil;
	[gravatarURL release], gravatarURL = nil;
	[gravatar release], gravatar = nil;
	[publicMembers release], publicMembers = nil;
	[publicRepositories release], publicRepositories = nil;
	[recentActivity release], recentActivity = nil;
    [super dealloc];
}

- (NSUInteger)hash {
	NSString *hashValue = [login lowercaseString];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHOrganization login:'%@' status:'%d' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@' publicRepoCount:'%d' privateRepoCount:'%d'>", login, loadingStatus, name, email, company, location, blogURL, publicRepoCount, privateRepoCount];
}

- (int)compareByName:(GHOrganization *)theOtherOrg {
    return [login localizedCaseInsensitiveCompare:[theOtherOrg login]];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kLoginDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
    NSURL *activityFeedURL = [NSURL URLWithFormat:kOrganizationFeedFormat, login, username, token];
	NSURL *repositoriesURL = [NSURL URLWithFormat:kOrganizationPublicRepositoriesFormat, login];
	NSURL *membersURL = [NSURL URLWithFormat:kOrganizationMembersFormat, login];

    self.resourceURL = [NSURL URLWithFormat:kOrganizationFormat, login];
	self.publicRepositories = [GHRepositories repositoriesWithURL:repositoriesURL];
	self.publicMembers = [GHUsers usersWithURL:membersURL];
    self.recentActivity = [GHFeed resourceWithURL:activityFeedURL];
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
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
