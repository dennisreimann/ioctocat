#import "iOctocatUnitTests.h"
#import "iOctocat.h"
#import "iOctocat+Private.h"


@implementation iOctocatUnitTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGravatarPathForIdentifier {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *expected = [documentsPath stringByAppendingPathComponent:@"dennisreimann.png"];
    NSString *actual = [iOctocat gravatarPathForIdentifier:@"dennisreimann"];
	STAssertEqualObjects(expected, actual, @"Paths do not match");
}

@end