#import "GHOrganization.h"
#import "GHUser.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GravatarLoader.h"
#import "GHReposParserDelegate.h"
#import "GHUsersParserDelegate.h"
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
@synthesize user;

+ (id)organization {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)organizationWithLogin:(NSString *)theLogin {
	GHOrganization *org = [GHOrganization organization];
	org.login = theLogin;
	return org;
}

- (id)init {
	[super init];
	gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [UIImage imageWithContentsOfFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login]];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[login release], login = nil;
	[email release], email = nil;
	[company release], company = nil;
	[blogURL release], blogURL = nil;
	[location release], location = nil;
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

#pragma mark User loading

- (void)parseData:(NSData *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:data error:&parseError];
    id res = parseError ? (id)parseError : (id)[dict objectForKey:@"commit"];
	[self performSelectorOnMainThread:@selector(parsingFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
        self.name = [theResult objectForKey:@"name"];
		self.company = [theResult objectForKey:@"company"];
        self.gravatarHash = [theResult objectForKey:@"gravatar_id"];
        self.location = [theResult objectForKey:@"location"];
        self.blogURL = [NSURL URLWithString:[theResult objectForKey:@"blog"]];
        self.publicGistCount = [theResult integerForKey:@"public_gist_count"];
        self.publicRepoCount = [theResult integerForKey:@"public_repo_count"];
        self.login = [theResult objectForKey:@"login"];
        self.email = [theResult objectForKey:@"email"];
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
