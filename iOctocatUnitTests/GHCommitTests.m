#import "IOCTestHelper.h"
#import "GHCommitTests.h"
#import "GHCommit.h"
#import "GHFiles.h"
#import "GHRepository.h"
#import "GHAccount.h"
#import "iOctocat.h"


@interface GHCommitTests ()
@property(nonatomic,strong)GHCommit *commit;
@end


@implementation GHCommitTests

- (void)setUp {
    [super setUp];
    iOctocat.sharedInstance.currentAccount = [[GHAccount alloc] initWithDict:@{}];
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

- (void)testShortenedSHA {
	expect(self.commit.shortenedSha).to.equal(@"thelong");
}

- (void)testShortenedMessage {
	self.commit.message = @"Refactoring: PullRequestController\n\nUse blocks instead of KVO";
	expect(self.commit.shortenedMessage).to.equal(@"Refactoring: PullRequestController");
}

- (void)testExtendedMessage {
	self.commit.message = @"Refactoring: PullRequestController\n\nUse blocks instead of KVO\nTest 1\n\nTest 2\n";
	expect(self.commit.extendedMessage).to.equal(@"Use blocks instead of KVO\nTest 1\n\nTest 2");
}

@end