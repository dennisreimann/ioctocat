#import "GHAccount.h"
#import "GHApiClient.h"
#import "GHUser.h"
#import "GHGists.h"
#import "GHEvents.h"
#import "GHRepositories.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "AFOAuth2Client.h"


@interface GHAccount ()
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *endpoint;
@property(nonatomic,strong)NSString *authToken;
@end


@implementation GHAccount

static int userOrgsObservanceContext;

- (id)initWithDict:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		self.login = [dict safeStringForKey:kLoginDefaultsKey];
		self.endpoint = [dict safeStringForKey:kEndpointDefaultsKey];
		self.authToken = [dict safeStringForKey:kAuthTokenDefaultsKey];
		// construct endpoint URL and set up API client
		NSURL *apiURL = [NSURL URLWithString:kGitHubApiURL];
		if (![self.endpoint isEmpty]) {
			apiURL = [[NSURL URLWithString:self.endpoint] URLByAppendingPathComponent:kEnterpriseApiPath];
		}
		self.apiClient = [[GHApiClient alloc] initWithBaseURL:apiURL];
		[self.apiClient setAuthorizationHeaderWithToken:self.authToken];
		// user with authenticated URLs
		self.user = [[iOctocat sharedInstance] userWithLogin:self.login];
		self.user.resourcePath = kUserAuthenticatedFormat;
		self.user.repositories.resourcePath = kUserAuthenticatedReposFormat;
		self.user.organizations.resourcePath = kUserAuthenticatedOrgsFormat;
		self.user.gists.resourcePath = kUserAuthenticatedGistsFormat;
		self.user.starredGists.resourcePath = kUserAuthenticatedGistsStarredFormat;
		self.user.starredRepositories.resourcePath = kUserAuthenticatedStarredReposFormat;
		self.user.watchedRepositories.resourcePath = kUserAuthenticatedWatchedReposFormat;
		[self.user.organizations addObserver:self
								  forKeyPath:kResourceLoadingStatusKeyPath
									 options:NSKeyValueObservingOptionNew
									 context:&userOrgsObservanceContext];
	}
	return self;
}

- (void)dealloc {
	[self.user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath context:&userOrgsObservanceContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &userOrgsObservanceContext && self.user.organizations.isLoaded) {
		for (GHOrganization *org in self.user.organizations.items) {
			org.events.resourcePath = [NSString stringWithFormat:kUserAuthenticatedOrgEventsFormat, self.login, org.login];
		}
	}
}

@end