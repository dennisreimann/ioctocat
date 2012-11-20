#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHUsers

@synthesize users;

+ (id)usersWithPath:(NSString *)thePath {
	return [[[[self class] alloc] initWithPath:thePath] autorelease];
}

- (id)initWithPath:(NSString *)thePath {
	[super init];
	self.users = [NSMutableArray array];
	self.resourcePath = thePath;
	return self;
}

- (void)dealloc {
	[users release], users = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHUsers resourcePath:'%@'>", resourcePath];
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