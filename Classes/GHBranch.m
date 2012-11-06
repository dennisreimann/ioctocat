#import "GHBranch.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHBranch

@synthesize repository;
@synthesize name;
@synthesize sha;

- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName {
	[super init];
	self.repository = theRepository;
	self.name = theName;
    return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[name release], name = nil;
	[sha release], sha = nil;
	[super dealloc];
}

@end
