#import "GHRepositories.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHRepositories

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
		self.repositories = [NSMutableArray array];
	}
	return self;
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		id own = dict[@"owner"];
		NSString *owner = [own isKindOfClass:[NSDictionary class]] ? own[@"login"] : own;
		GHRepository *resource = [[GHRepository alloc] initWithOwner:owner andName:dict[@"name"]];
		[resource setValues:dict];
		[resources addObject:resource];
	}
	[resources sortUsingSelector:@selector(compareByName:)];
	self.repositories = resources;
}

@end