#import "GHForks.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHForks ()
@property(nonatomic,weak)GHRepository *repository;
@end


@implementation GHForks

- (id)initWithRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoForksFormat, repo.owner, repo.name];
	self = [super initWithPath:path];
	if (self) {
		self.repository = repo;
	}
	return self;
}

@end