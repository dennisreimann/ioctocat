#import "GHAccount.h"
#import "GHUser.h"


@implementation GHAccount

@synthesize user;
@synthesize login;
@synthesize password;
@synthesize token;
@synthesize endpoint;

+ (id)accountWithDict:(NSDictionary *)theDict {
	return [[[[self class] alloc] initWithDict:theDict] autorelease];
}

- (id)initWithDict:(NSDictionary *)theDict {
	[super init];
	self.login = [theDict valueForKey:kLoginDefaultsKey];
	self.password = [theDict valueForKey:kPasswordDefaultsKey];
	self.token = [theDict valueForKey:kTokenDefaultsKey];
	self.endpoint = [theDict valueForKey:kEndpointDefaultsKey];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
    return self;
}

- (void)dealloc {
    [user release], user = nil;
    [login release], login = nil;
    [password release], password = nil;
	[token release], token = nil;
	[endpoint release], endpoint = nil;
	[super dealloc];
}

@end
