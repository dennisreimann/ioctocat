#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@interface GHUsers ()
- (void)parseUsers;
@end


@implementation GHUsers

@synthesize user, users, usersURL;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
    [super init];
    self.user = theUser;
	self.users = [NSMutableArray array];
    self.usersURL = theURL;
	return self;    
}

- (void)dealloc {
	[user release];
	[users release];
	[usersURL release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUsers user:'%@' usersURL:'%@'>", user, usersURL];
}

- (void)loadUsers {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseUsers) withObject:nil];
}

- (void)parseUsers {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:usersURL];    
	[request start];
	NSError *parseError = nil;
    NSDictionary *usersDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
    for (NSString *login in [usersDict objectForKey:@"users"]) {
		GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
        [resources addObject:theUser];
    }
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(loadedUsers:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)loadedUsers:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		[theResult sortUsingSelector:@selector(compareByName:)];
		self.users = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
