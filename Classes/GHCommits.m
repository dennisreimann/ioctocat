#import "GHCommits.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHPullRequest.h"
#import "NSDictionary+Extensions.h"


@interface GHCommits ()
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHPullRequest *pullRequest;
@end


@implementation GHCommits

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitsFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (id)initWithPullRequest:(GHPullRequest *)pullRequest {
	self = [super init];
	if (self) {
		self.pullRequest = pullRequest;
		self.repository = self.pullRequest.repository;
	}
	return self;
}

// Dynamic resourcePath, because it depends on the
// num which isn't always available in advance
- (NSString *)resourcePath {
	if (self.pullRequest) {
		GHRepository *repo = self.pullRequest.repository;
		return [NSString stringWithFormat:kPullRequestCommitsFormat, repo.owner, repo.name, self.pullRequest.num];
	} else {
		return [super resourcePath];
	}
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
