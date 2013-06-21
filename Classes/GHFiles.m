#import "GHFiles.h"
#import "GHResource.h"
#import "GHRepository.h"
#import "GHPullRequest.h"
#import "NSDictionary_IOCExtensions.h"


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

- (NSString *)resourcePath {
	if (self.pullRequest) {
		return [NSString stringWithFormat:kPullRequestFilesFormat, self.pullRequest.repository.owner, self.pullRequest.repository.name, self.pullRequest.number];
	} else {
		return [super resourcePath];
	}
}

- (void)setValues:(id)values {
    self.items = values;
}

@end
