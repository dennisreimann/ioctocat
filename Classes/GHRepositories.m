#import "GHRepositories.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHRepositories

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		id own = dict[@"owner"];
		NSString *owner = [own isKindOfClass:[NSDictionary class]] ? own[@"login"] : own;
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:dict[@"name"]];
		[repo setValues:dict];
		[self addObject:repo];
	}
	[self.items sortUsingSelector:@selector(compareByName:)];
}

@end