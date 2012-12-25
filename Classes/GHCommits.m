#import "GHCommits.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"


@implementation GHCommits

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitsFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)values {
    self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
        NSString *sha = [dict safeStringForKey:@"sha"];
		GHCommit *commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
		[commit setValues:dict];
		[self addObject:commit];
    }
}

@end
