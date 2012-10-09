#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranches

@synthesize branches;
@synthesize repository;

+ (id)branchesWithRepository:(GHRepository *)theRepository {
	return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	[super init];
	self.repository = theRepository;
	self.branches = [NSMutableArray array];
	self.resourcePath = [NSString stringWithFormat:kRepoBranchesFormat, repository.owner, repository.name];
	return self;
}

- (void)dealloc {
	[branches release], branches = nil;
	[repository release], repository = nil;
	[super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHBranches repository:'%@'>", repository];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *branchDict in theDict) {
        NSString *name = [branchDict valueForKey:@"name"];
		GHBranch *branch = [[GHBranch alloc] initWithRepository:repository andName:name];
		branch.sha = [branchDict valueForKeyPath:@"commit.sha"];
		if ([branch.name isEqualToString:repository.mainBranch]) {
			[resources insertObject:branch atIndex:0];
		} else {
			[resources addObject:branch];
		}
		[branch release];
    }
    self.branches = resources;
}

@end
