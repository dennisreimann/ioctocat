#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranch

+ (id)branchWithRepository:(GHRepository *)theRepository andName:(NSString *)theName {
	return [[self.class alloc] initWithRepository:theRepository andName:theName];
}

- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.name = theName;
	}
	return self;
}

@end