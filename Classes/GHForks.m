#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHForks

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.resourcePath = [NSString stringWithFormat:kRepoForksFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *repoDict in theResponse) {
		NSString *owner = [repoDict valueForKeyPath:@"owner.login"];
		NSString *name = [repoDict valueForKey:@"name"];
		GHRepository *resource = [[GHRepository alloc] initWithOwner:owner andName:name];
		[resource setValues:repoDict];
		[resources addObject:resource];
	}
	[resources sortUsingSelector:@selector(compareByName:)];
	self.entries = resources;
}

@end