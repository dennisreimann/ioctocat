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
	NSString *repositoriesURLString = [NSString stringWithFormat:kOrganizationPublicRepositoriesFormat, login];
	NSURL *repositoriesURL = [NSURL URLWithString:repositoriesURLString];
	self.publicRepositories = [GHRepositories repositoriesWithURL:repositoriesURL];
	// Recent Activity
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kLoginDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *activityFeedURLString = [NSString stringWithFormat:kOrganizationFeedFormat, login, username, token];
    NSURL *activityFeedURL = [NSURL URLWithString:activityFeedURLString];
    self.recentActivity = [GHFeed resourceWithURL:activityFeedURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *org = [theDict objectForKey:@"organization"];
    
    self.name = [org objectForKey:@"name"];
    self.company = [org objectForKey:@"company"];
    self.gravatarHash = [org objectForKey:@"gravatar_id"];
    self.location = [org objectForKey:@"location"];
    self.blogURL = [NSURL URLWithString:[org objectForKey:@"blog"]];
    self.publicGistCount = (NSUInteger)[org objectForKey:@"public_gist_count"];
    self.publicRepoCount = (NSUInteger)[org objectForKey:@"public_repo_count"];
    self.login = [org objectForKey:@"login"];
    self.email = [org objectForKey:@"email"];
}

#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
