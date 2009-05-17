#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"
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
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseUsers) withObject:nil];
}

- (void)parseUsers {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:usersURL];    
	[request start];
	NSError *parseError = nil;
    NSDictionary *usersDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *login in [usersDict objectForKey:@"users"]) {
		GHUser *theUser = [appDelegate userWithLogin:login];
        [resources addObject:theUser];
    }
    id result = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(loadedUsers:) withObject:result waitUntilDone:YES];
    [pool release];
}

- (void)loadedUsers:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.users = theResult;
		self.status = GHResourceStatusLoaded;
	}
}

@end
