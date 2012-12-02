#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHUsers

+ (id)usersWithPath:(NSString *)thePath {
	return [[self.class alloc] initWithPath:thePath];
}

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.users = [NSMutableArray array];
		self.resourcePath = thePath;
	}
	return self;
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *userDict in theResponse) {
		NSString *login = [userDict objectForKey:@"login"];
		GHUser *theUser = [[iOctocat sharedInstance] userWithLogin:login];
		[theUser setValues:userDict];
		[resources addObject:theUser];
	}
	[resources sortUsingSelector:@selector(compareByName:)];
	self.users = resources;
}

@end