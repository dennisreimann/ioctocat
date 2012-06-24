#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHForks

@synthesize entries;
@synthesize repository;

+ (id)forksWithRepository:(GHRepository *)theRepository {
	return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
    [super init];
    self.repository = theRepository;
	self.resourcePath = [NSString stringWithFormat:kRepoForksFormat, repository.owner, repository.name];
	return self;    
}

- (void)dealloc {
	[repository release], repository = nil;
	[entries release], entries = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHForks repository:'%@'>", repository];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *repoDict in theDict) {
        NSString *owner = [repoDict valueForKeyPath:@"owner.login"];
        NSString *name = [repoDict valueForKey:@"name"];
		GHRepository *resource = [GHRepository repositoryWithOwner:owner andName:name];
        [resource setValuesFromDict:repoDict];
        [resources addObject:resource];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.entries = resources;
}

@end
