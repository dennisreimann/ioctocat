#import "GHFiles.h"
#import "GHResource.h"
#import "GHRepository.h"
#import "GHPullRequest.h"
#import "NSDictionary+Extensions.h"


@interface GHFiles ()
@property(nonatomic,weak)GHPullRequest *pullRequest;
@end


@implementation GHFiles

- (id)initWithPullRequest:(GHPullRequest *)pullRequest {
	self = [self init];
	if (self) {
		self.pullRequest = pullRequest;
	}
	return self;
}

// Dynamic resourcePath, because it depends on the
// num which isn't always available in advance
- (NSString *)resourcePath {
	if (self.pullRequest) {
		GHRepository *repo = self.pullRequest.repository;
		return [NSString stringWithFormat:kPullRequestFilesFormat, repo.owner, repo.name, self.pullRequest.number];
	} else {
		return [super resourcePath];
	}
}

- (void)setValues:(id)values {
    self.items = values;
}

@end
