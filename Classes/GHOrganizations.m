#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHOrganizations

- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.user = theUser;
		self.organizations = [NSMutableArray array];
		self.resourcePath = thePath;
	}
	return self;
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHOrganization *theOrg = [[iOctocat sharedInstance] organizationWithLogin:dict[@"login"]];
		[theOrg setValues:dict];
		[resources addObject:theOrg];
	}
	[resources sortUsingSelector:@selector(compareByName:)];
	self.organizations = resources;
}

@end