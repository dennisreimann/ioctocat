#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"


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
	[user release], user = nil;
	[users release], users = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUsers user:'%@' resourceURL:'%@'>", user, resourceURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSString *login in [theDict objectForKey:@"users"]) {
		GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
        [resources addObject:theUser];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.users = resources;
}

@end
