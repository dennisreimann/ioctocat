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


@implementation GHAccount

- (id)initWithDict:(NSDictionary *)theDict {
	self = [super init];
	if (self) {
		self.login = [theDict valueForKey:kLoginDefaultsKey defaultsTo:@""];
		self.password = [theDict valueForKey:kPasswordDefaultsKey defaultsTo:@""];
		self.endpoint = [theDict valueForKey:kEndpointDefaultsKey defaultsTo:@""];
		// construct endpoint URL and set up API client
		NSURL *apiURL = [NSURL URLWithString:kGitHubApiURL];
		if (![self.endpoint isEmpty]) {
			apiURL = [[NSURL URLWithString:self.endpoint] URLByAppendingPathComponent:kEnterpriseApiPath];
		}
		self.apiClient = [[GHApiClient alloc] initWithBaseURL:apiURL];
		[self.apiClient setAuthorizationHeaderWithUsername:self.login password:self.password];
		// user with authenticated URLs
		self.user = [[iOctocat sharedInstance] userWithLogin:self.login];
		self.user.resourcePath = kUserAuthenticatedFormat;
		self.user.repositories.resourcePath = kUserAuthenticatedReposFormat;
		self.user.organizations.resourcePath = kUserAuthenticatedOrgsFormat;
		self.user.gists.resourcePath = kUserAuthenticatedGistsFormat;
		self.user.starredGists.resourcePath = kUserAuthenticatedGistsStarredFormat;
		self.user.starredRepositories.resourcePath = kUserAuthenticatedStarredReposFormat;
		self.user.watchedRepositories.resourcePath = kUserAuthenticatedWatchedReposFormat;
		[self.user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath] && object == self.user.organizations && self.user.organizations.isLoaded) {
		for (GHOrganization *org in self.user.organizations.organizations) {
			org.events.resourcePath = [NSString stringWithFormat:kUserAuthenticatedOrgEventsFormat, self.login, org.login];
		}
	}
}

@end