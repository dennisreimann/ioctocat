#import "GHRepositories.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@implementation GHRepositories

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if (self) {
		self.resourcePath = path;
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		id own = dict[@"owner"];
		NSString *owner = [own isKindOfClass:NSDictionary.class] ? [own safeStringForKey:@"login"] : own;
		NSString *name = [dict safeStringForKey:@"name"];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		[repo setValues:dict];
		[self addObject:repo];
	}
	[self.items sortUsingSelector:@selector(compareByName:)];
}

@end