#import "GHAccount.h"
#import "GHUser.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"


@implementation GHAccount

@synthesize user;
@synthesize login;
@synthesize password;
@synthesize token;
@synthesize endpoint;
@synthesize endpointURL;
@synthesize apiURL;

+ (id)accountWithDict:(NSDictionary *)theDict {
	return [[[[self class] alloc] initWithDict:theDict] autorelease];
}

- (id)dictionary:(NSDictionary *)dict valueForKey:(NSString *)key defaultsTo:(id)defaultValue {
    id value = [dict valueForKey:key];
    return (value != nil) ? value : defaultValue;
}

- (id)initWithDict:(NSDictionary *)theDict {
	[super init];
	
	self.login = [self dictionary:theDict valueForKey:kLoginDefaultsKey defaultsTo:@""];
	self.password = [self dictionary:theDict valueForKey:kPasswordDefaultsKey defaultsTo:@""];
	self.token = [self dictionary:theDict valueForKey:kTokenDefaultsKey defaultsTo:@""];
	self.endpoint = [self dictionary:theDict valueForKey:kEndpointDefaultsKey defaultsTo:@""];
	
	// construct endpoint URL
	if ([endpoint isEmpty]) {
		self.endpointURL = [NSURL URLWithString:kGitHubBaseURL];
		self.apiURL = [NSURL URLWithString:kGitHubApiURL];
	} else {
		self.endpointURL = [NSURL URLWithString:endpoint];
		self.apiURL = [endpointURL URLByAppendingPathComponent:kEnterpriseApiPath];
	}
	
	// user with authenticated URLs
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.user.resourcePath = kUserAuthenticatedFormat;
	self.user.repositories.resourcePath = kUserAuthenticatedReposFormat;
	self.user.organizations.resourcePath = kUserAuthenticatedOrgsFormat;
	
    return self;
}

- (void)dealloc {
    [user release], user = nil;
    [login release], login = nil;
    [password release], password = nil;
	[token release], token = nil;
	[endpoint release], endpoint = nil;
	[endpointURL release], endpointURL = nil;
	[super dealloc];
}

@end
