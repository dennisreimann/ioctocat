#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHOrganizations

@synthesize user, organizations;

+ (id)organizationsWithUser:(GHUser *)theUser andPath:(NSString *)thePath {
    return [[[[self class] alloc] initWithUser:theUser andPath:thePath] autorelease];
}

- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath {
    [super init];
    self.user = theUser;
	self.organizations = [NSMutableArray array];
    self.resourcePath = thePath;
	return self;    
}

- (void)dealloc {
	[user release], user = nil;
	[organizations release], organizations = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHOrganizations user:'%@' resourcePath:'%@'>", user, self.resourcePath];
}

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in theResponse) {
		GHOrganization *theOrg = [[iOctocat sharedInstance] organizationWithLogin:[dict objectForKey:@"login"]];
        [theOrg setValues:dict];
        [resources addObject:theOrg];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.organizations = resources;
}

@end
