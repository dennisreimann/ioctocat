#import "GHAccount.h"
#import "GHApiClient.h"
#import "GHUser.h"
#import "GHGists.h"
#import "GHEvents.h"
#import "GHRepositories.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
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

NSString *const OrgsLoadingKeyPath = @"organizations.loadingStatus";

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
		self.user.notifications = [[GHNotifications alloc] initWithPath:kNotificationsPath];
		[self.user addObserver:self forKeyPath:OrgsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:OrgsLoadingKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (self.user.organizations.isLoaded) {
		for (GHOrganization *org in self.user.organizations.items) {
			org.events.resourcePath = [NSString stringWithFormat:kUserAuthenticatedOrgEventsFormat, self.login, org.login];
		}
	}
}

@end