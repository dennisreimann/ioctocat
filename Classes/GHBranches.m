#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranches

+ (id)branchesWithRepository:(GHRepository *)theRepository {
	return [[[self.class alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.branches = [NSMutableArray array];
		self.resourcePath = [NSString stringWithFormat:kRepoBranchesFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)dealloc {
	[_branches release], _branches = nil;
	[_repository release], _repository = nil;
	[super dealloc];
}

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *branchDict in theResponse) {
        NSString *name = [branchDict valueForKey:@"name"];
		GHBranch *branch = [GHBranch branchWithRepository:self.repository andName:name];
		branch.sha = [branchDict valueForKeyPath:@"commit.sha"];
		if ([branch.name isEqualToString:self.repository.mainBranch]) {
			[resources insertObject:branch atIndex:0];
		} else {
			[resources addObject:branch];
		}
    }
    self.branches = resources;
}

@end
