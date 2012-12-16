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
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"Commit-Large"];
	[self.commit setValues:dict];
	expect(self.commit.added.count).to.equal(16);
	expect(self.commit.removed.count).to.equal(3);
	expect(self.commit.modified.count).to.equal(26);
}

@end