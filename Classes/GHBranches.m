#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranches

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.resourcePath = [NSString stringWithFormat:kRepoBranchesFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)values {
    self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
        NSString *name = [dict valueForKey:@"name"];
		GHBranch *branch = [[GHBranch alloc] initWithRepository:self.repository andName:name];
		branch.sha = [dict valueForKeyPath:@"commit.sha"];
		if ([branch.name isEqualToString:self.repository.mainBranch]) {
			[self insertObject:branch atIndex:0];
		} else {
			[self addObject:branch];
		}
    }
}

@end
