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
@synthesize gravatarHash;
@synthesize gravatar;
@synthesize publicMembers;
@synthesize publicRepositories;
@synthesize recentActivity;
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
    self.resourceURL = [NSURL URLWithFormat:kOrganizationFormat, login];
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
	[gravatarHash release], gravatarHash = nil;
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
	// Repositories
	NSURL *repositoriesURL = [NSURL URLWithFormat:kOrganizationPublicRepositoriesFormat, login];
	self.publicRepositories = [GHRepositories repositoriesWithURL:repositoriesURL];
	// Recent Activity
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kLoginDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
    NSURL *activityFeedURL = [NSURL URLWithFormat:kOrganizationFeedFormat, login, username, token];
    self.recentActivity = [GHFeed resourceWithURL:activityFeedURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *org = [theDict objectForKey:@"organization"];
    
    self.login = [org objectForKey:@"login"];
    self.email = [org objectForKey:@"email"];
    self.name = [org objectForKey:@"name"];
    self.company = [org objectForKey:@"company"];
    self.gravatarHash = [org objectForKey:@"gravatar_id"];
    self.location = [org objectForKey:@"location"];
    self.publicGistCount = [[org objectForKey:@"public_gist_count"] integerValue];
    self.publicRepoCount = [[org objectForKey:@"public_repo_count"] integerValue];
    self.blogURL = [[org objectForKey:@"blog"] isKindOfClass:[NSNull class]] ? nil : [NSURL URLWithString:[org objectForKey:@"blog"]];
}

#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
