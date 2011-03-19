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
    for (id item in [theDict objectForKey:@"users"]) {
        NSString *login = ([item isKindOfClass:[NSString class]]) ? item : [item objectForKey:@"login"];
		GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
        if ([item isKindOfClass:[NSDictionary class]]) [theUser setValuesFromDict:item];
        [resources addObject:theUser];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.users = resources;
}

@end
