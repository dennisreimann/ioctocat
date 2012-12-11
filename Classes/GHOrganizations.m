#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHOrganizations

- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.user = theUser;
		self.resourcePath = thePath;
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHOrganization *org = [[iOctocat sharedInstance] organizationWithLogin:dict[@"login"]];
		[org setValues:dict];
		[self addObject:org];
	}
	[self.items sortUsingSelector:@selector(compareByName:)];
}

@end