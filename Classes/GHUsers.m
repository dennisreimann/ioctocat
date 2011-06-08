#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHUsers

@synthesize users;

+ (id)usersWithURL:(NSURL *)theURL {
    return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
    [super init];
	self.users = [NSMutableArray array];
    self.resourceURL = theURL;
	return self;    
}

- (void)dealloc {
	[users release], users = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUsers resourceURL:'%@'>", resourceURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    // This looks weird, but we'll have to do it like that for
    // the time we are switching from API v2 to v3…
    NSArray *usersArray = [theDict isKindOfClass:[NSArray class]] ? theDict : [theDict objectForKey:@"users"];
    for (NSDictionary *userDict in usersArray) {
        NSString *login = [userDict objectForKey:@"login"];
        GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
        [theUser setValuesFromDict:userDict];
        [resources addObject:theUser];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.users = resources;
}

@end
