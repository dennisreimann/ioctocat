#import "IOCTestHelper.h"
#import "GHCommitTests.h"
#import "GHCommit.h"
#import "GHRepository.h"


@interface GHCommitTests ()
@property(nonatomic,strong)GHCommit *commit;
@end


@implementation GHCommitTests

- (void)setUp {
    [super setUp];
	GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
	self.commit = [[GHCommit alloc] initWithRepository:repo andCommitID:@"thelongsha123"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFiles {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"LargeCommit"];
	[self.commit setValues:dict];
	STAssertTrue(16 == self.commit.added.count, @"Added files count is incorrect");
	STAssertTrue(3 == self.commit.removed.count, @"Removed files count is incorrect");
	STAssertTrue(26 == self.commit.modified.count, @"Modified files count is incorrect");
}

@end