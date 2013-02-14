#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"


@implementation GHForks

- (id)initWithRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoForksFormat, repo.owner, repo.name];
	self = [super initWithPath:path];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		NSString *owner = [dict safeStringForKeyPath:@"owner.login"];
		NSString *name = [dict safeStringForKey:@"name"];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		[repo setValues:dict];
		[self addObject:repo];
	}
	[self sortUsingSelector:@selector(compareByName:)];
}

@end