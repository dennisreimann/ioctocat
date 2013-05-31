#import "GHResource.h"
#import "GHReadme.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHReadme

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithRepo:repo path:nil ref:nil];
	if (self) {
		self.resourcePath = [NSString stringWithFormat:kRepoReadmeFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

@end