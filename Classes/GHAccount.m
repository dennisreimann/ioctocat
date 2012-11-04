#import "GHAccount.h"
#import "GHApiClient.h"
#import "GHFeedClient.h"
#import "GHUser.h"
#import "GHGists.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHAccount

@synthesize apiClient;
@synthesize feedClient;
@synthesize user;
@synthesize login;
@synthesize password;
@synthesize endpoint;
@synthesize endpointURL;
@synthesize apiURL;

+ (id)accountWithDict:(NSDictionary *)theDict {
	return [[[[self class] alloc] initWithDict:theDict] autorelease];
}

- (id)initWithDict:(NSDictionary *)theDict {
	[super init];
	
	self.login = [theDict valueForKey:kLoginDefaultsKey defaultsTo:@""];
	self.password = [theDict valueForKey:kPasswordDefaultsKey defaultsTo:@""];
	self.endpoint = [theDict valueForKey:kEndpointDefaultsKey defaultsTo:@""];
	
	// construct endpoint URL and set up API client
	if ([endpoint isEmpty]) {
		self.endpointURL = [NSURL URLWithString:kGitHubBaseURL];
		self.apiURL = [NSURL URLWithString:kGitHubApiURL];
	} else {
		self.endpointURL = [NSURL URLWithString:endpoint];
		self.apiURL = [endpointURL URLByAppendingPathComponent:kEnterpriseApiPath];
	}
	self.apiClient = [GHApiClient clientWithBaseURL:apiURL];
	[self.apiClient setAuthorizationHeaderWithUsername:login password:password];
	self.feedClient = [GHFeedClient clientWithBaseURL:endpointURL];
	[self.feedClient setAuthorizationHeaderWithUsername:login password:password];
	
	// user with authenticated URLs
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.user.resourcePath = kUserAuthenticatedFormat;
	self.user.repositories.resourcePath = kUserAuthenticatedReposFormat;
	self.user.organizations.resourcePath = kUserAuthenticatedOrgsFormat;
	self.user.gists.resourcePath = kUserAuthenticatedGistsFormat;
	self.user.starredGists.resourcePath = kUserAuthenticatedGistsStarredFormat;
	self.user.starredRepositories.resourcePath = kUserAuthenticatedStarredReposFormat;
	self.user.watchedRepositories.resourcePath = kUserAuthenticatedWatchedReposFormat;
	
    return self;
}

- (void)dealloc {
    [user release], user = nil;
    [login release], login = nil;
    [password release], password = nil;
	[endpoint release], endpoint = nil;
	[endpointURL release], endpointURL = nil;
	[super dealloc];
}

@end
