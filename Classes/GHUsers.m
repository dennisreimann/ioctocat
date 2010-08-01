#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@implementation GHUsers

@synthesize user, users;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
    [super init];
    self.user = theUser;
	self.users = [NSMutableArray array];
    self.resourceURL = theURL;
	return self;    
}

- (void)dealloc {
	[user release];
	[users release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUsers user:'%@' resourceURL:'%@'>", user, resourceURL];
}

- (void)parseData:(NSData *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *usersDict = [[CJSONDeserializer deserializer] deserialize:data error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
    for (NSString *login in [usersDict objectForKey:@"users"]) {
		GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
        [resources addObject:theUser];
    }
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(parsingFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingFinished:(id)theResult {
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
