#include "TargetConditionals.h"
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <SenTestingKit/SenTestingKit.h>
#import "GHResource.h"


@interface GHResourceTestCase : SenTestCase {
	GHResource *resource;
}
@end


@implementation GHResourceTestCase

- (void)setUp {
	[super setUp];
	resource = [[GHResource alloc] init];
}

- (void)tearDown {
	[resource release];
	[super tearDown];
}

- (void)testStatusShouldInitiallyBeSetToNotLoaded {
    STAssertEquals(resource.status, GHResourceStatusNotLoaded, @"status should be NotLoaded");
}

- (void)testErrorShouldInitiallyBeSetToNil {
    STAssertEqualObjects(resource.error, nil, @"error should be nil");
}

@end

#endif