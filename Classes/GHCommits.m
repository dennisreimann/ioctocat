#import "GHCommits.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHPullRequest.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHCommits ()
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,weak)GHPullRequest *pullRequest;
@property(nonatomic,strong)NSString *sha;
@end


@implementation GHCommits

@synthesize resourcePath = _resourcePath;

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitsFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo sha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
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

- (NSString *)resourcePath {
	if (_resourcePath) {
        // in events there is no resourcePath that could be referenced, so we clear
        // out the resourcePath with an empty string which should be returned then
		return _resourcePath;
	} else if (self.pullRequest) {
		GHRepository *repo = self.pullRequest.repository;
		return [NSString stringWithFormat:kPullRequestCommitsFormat, repo.owner, repo.name, self.pullRequest.number];
	} else if (self.sha) {
		return [NSString stringWithFormat:kRepoShaCommitsFormat, self.repository.owner, self.repository.name, self.sha];
	} else {
		return [super resourcePath];
	}
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *sha = [dict ioc_stringForKey:@"sha"];
		GHCommit *commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
		[commit setValues:dict];
		[self addObject:commit];
    }
}

@end
