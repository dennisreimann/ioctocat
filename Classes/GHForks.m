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

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *repoDict in theResponse) {
        NSString *owner = [repoDict valueForKeyPath:@"owner.login"];
        NSString *name = [repoDict valueForKey:@"name"];
		GHRepository *resource = [GHRepository repositoryWithOwner:owner andName:name];
        [resource setValues:repoDict];
        [resources addObject:resource];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.entries = resources;
}

@end
