#import "GHAccount.h"
#import "GHOAuthClient.h"
#import "GHUserObjectsRepository.h"
#import "GHUser.h"
#import "GHGists.h"
#import "GHEvents.h"
#import "GHRepositories.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "AFOAuth2Client.h"


@interface GHAccount ()
@property(nonatomic,strong)GHUserObjectsRepository *userObjects;
@end


@implementation GHAccount

static NSString *const LoginKeyPath = @"login";
static NSString *const OrgsLoadingKeyPath = @"organizations.resourceStatus";

- (id)initWithDict:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		self.userObjects = [[GHUserObjectsRepository alloc] init];
		self.login       = [dict ioc_stringForKey:kLoginDefaultsKey];
		self.endpoint    = [dict ioc_stringForKey:kEndpointDefaultsKey];
		self.authToken   = [dict ioc_stringForKey:kAuthTokenDefaultsKey];
		self.pushToken   = [dict ioc_stringForKey:kPushTokenDefaultsKey];
	}
	return self;
}

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:OrgsLoadingKeyPath];
	[self.user removeObserver:self forKeyPath:LoginKeyPath];
}

// constructs endpoint URL and sets up API client
- (GHOAuthClient *)apiClient {
    if (!_apiClient) {
        NSURL *apiURL = self.isGitHub ?
            [NSURL URLWithString:kGitHubApiURL] :
            [[NSURL URLWithString:self.endpoint] URLByAppendingPathComponent:kEnterpriseApiPath];
        self.apiClient = [[GHOAuthClient alloc] initWithBaseURL:apiURL];
        [_apiClient setAuthorizationHeaderWithToken:self.authToken];
    }
    return _apiClient;
}

// invalidates the apiClient when the endpoint changes
- (void)setEndpoint:(NSString *)endpoint {
    _endpoint = [[[NSURL ioc_smartURLFromString:endpoint defaultScheme:@"https"] ioc_URLByDeletingTrailingSlash] absoluteString];
    self.apiClient = nil;
}

// invalidates the apiClient when the authToken changes
- (void)setAuthToken:(NSString *)authToken {
    _authToken = authToken;
    self.apiClient = nil;
}

- (void)setLogin:(NSString *)login {
    if ([login isEqualToString:_login]) return;
    _login = login;
    // clean up old user
    [self.user removeObserver:self forKeyPath:OrgsLoadingKeyPath];
	[self.user removeObserver:self forKeyPath:LoginKeyPath];
    // construct user with authenticated URLs
    NSString *receivedEventsPath = [NSString stringWithFormat:kUserAuthenticatedReceivedEventsFormat, self.login];
    NSString *eventsPath = [NSString stringWithFormat:kUserAuthenticatedEventsFormat, self.login];
    self.user = [self.userObjects userWithLogin:self.login];
    self.user.resourcePath = kUserAuthenticatedFormat;
    self.user.repositories.resourcePath = kUserAuthenticatedReposFormat;
    self.user.organizations.resourcePath = kUserAuthenticatedOrgsFormat;
    self.user.gists.resourcePath = kUserAuthenticatedGistsFormat;
    self.user.starredGists.resourcePath = kUserAuthenticatedGistsStarredFormat;
    self.user.starredRepositories.resourcePath = kUserAuthenticatedStarredReposFormat;
    self.user.watchedRepositories.resourcePath = kUserAuthenticatedWatchedReposFormat;
    self.user.notifications = [[GHNotifications alloc] initWithPath:kNotificationsFormat];
    self.user.receivedEvents = [[GHEvents alloc] initWithPath:receivedEventsPath account:self];
    self.user.events = [[GHEvents alloc] initWithPath:eventsPath account:self];
    [self.user addObserver:self forKeyPath:LoginKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.user addObserver:self forKeyPath:OrgsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (NSString *)accountId {
    NSURL *url = [NSURL ioc_smartURLFromString:self.endpoint];
	if (!url) url = [NSURL URLWithString:kGitHubComURL];
    return [NSString stringWithFormat:@"%@/%@", url.host, self.login];
}

- (void)updateUserResourcePaths {
	self.user.receivedEvents.resourcePath = [NSString stringWithFormat:kUserAuthenticatedReceivedEventsFormat, self.user.login];
	self.user.events.resourcePath = [NSString stringWithFormat:kUserAuthenticatedEventsFormat, self.user.login];
	for (GHOrganization *org in self.user.organizations.items) {
		org.events.resourcePath = [NSString stringWithFormat:kUserAuthenticatedOrgEventsFormat, self.user.login, org.login];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:LoginKeyPath] || ([keyPath isEqualToString:OrgsLoadingKeyPath] && self.user.organizations.isLoaded)) {
		[self updateUserResourcePaths];
	}
	if ([keyPath isEqualToString:LoginKeyPath]) {
		self.login = self.user.login;
	}
}

- (BOOL)isGitHub {
    return !self.endpoint || [self.endpoint ioc_isEmpty] || [self.endpoint isEqualToString:kGitHubComURL];
}

#pragma mark Coding

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.login forKey:kLoginDefaultsKey];
	[encoder encodeObject:self.endpoint forKey:kEndpointDefaultsKey];
	[encoder encodeObject:self.authToken forKey:kAuthTokenDefaultsKey];
	[encoder encodeObject:self.pushToken forKey:kPushTokenDefaultsKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
	NSString *login = [decoder decodeObjectForKey:kLoginDefaultsKey];
	NSString *endpoint = [decoder decodeObjectForKey:kEndpointDefaultsKey];
	NSString *authToken = [decoder decodeObjectForKey:kAuthTokenDefaultsKey];
	NSString *pushToken = [decoder decodeObjectForKey:kPushTokenDefaultsKey];
    // for backwards compatibility: assign github.com if endpoint is empty
    if (!endpoint || [endpoint ioc_isEmpty]) endpoint = kGitHubComURL;
	self = [self initWithDict:@{
			kLoginDefaultsKey: login ? login : @"",
		 kEndpointDefaultsKey: endpoint ? endpoint : @"",
		kAuthTokenDefaultsKey: authToken ? authToken : @"",
		kPushTokenDefaultsKey: pushToken ? pushToken : @"" }];
	return self;
}

@end