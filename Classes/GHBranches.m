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
	self.resourceURL = [NSURL URLWithFormat:kRepoBranchesFormat, repository.owner, repository.name];
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
	for (NSString *branchName in [[theDict objectForKey:@"branches"] allKeys]) {
		GHBranch *branch = [[GHBranch alloc] initWithRepository:repository andName:branchName];
		branch.sha = [[theDict objectForKey:@"branches"] objectForKey:branchName];
        [resources addObject:branch];
		[branch release];
    }
    self.branches = resources;
}

@end
