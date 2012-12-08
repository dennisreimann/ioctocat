#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranch

- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.name = theName;
	}
	return self;
}

@end