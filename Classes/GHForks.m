#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHForks

+ (id)forksWithRepository:(GHRepository *)theRepository {
	return [[[self.class alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.resourcePath = [NSString stringWithFormat:kRepoForksFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)dealloc {
	[_repository release], _repository = nil;
	[_entries release], _entries = nil;
	[super dealloc];
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