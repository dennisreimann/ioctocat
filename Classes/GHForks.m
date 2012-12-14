#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHForks

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoForksFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		NSString *owner = [dict valueForKeyPath:@"owner.login"];
		NSString *name = [dict valueForKey:@"name"];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		[repo setValues:dict];
		[self addObject:repo];
	}
	[self.items sortUsingSelector:@selector(compareByName:)];
}

@end