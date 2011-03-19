#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHOrganizations

@synthesize user, organizations;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL {
    [super init];
    self.user = theUser;
	self.organizations = [NSMutableArray array];
    self.resourceURL = theURL;
	return self;    
}

- (void)dealloc {
	[user release], user = nil;
	[organizations release], organizations = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHOrganizations user:'%@' resourceURL:'%@'>", user, resourceURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSString *login in [theDict objectForKey:@"organizations"]) {
		GHOrganization *theOrg = [GHOrganization organizationWithLogin:login];
        [resources addObject:theOrg];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.organizations = resources;
}

@end
