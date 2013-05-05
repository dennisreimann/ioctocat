#import "IOCTestHelper.h"
#import "GHTreeTests.h"
#import "GHTree.h"
#import "GHRepository.h"


@interface GHTreeTests ()
@property(nonatomic,strong)GHTree *tree;
@end


@implementation GHTreeTests

- (void)setUp {
    [super setUp];
    GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
	self.tree = [[GHTree alloc] initWithRepo:repo path:@"" ref:@"master"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetValues {
    NSDictionary *dict = [IOCTestHelper jsonFixture:@"RepoContents"];
	[self.tree setValues:dict];
	expect(self.tree.trees.count).to.equal(1);
	expect(self.tree.blobs.count).to.equal(3);
	expect(self.tree.submodules.count).to.equal(1);
}

- (void)testShortenedSHA {
    self.tree.sha = @"4c8f9eca94857c4647ea6988491c9cec0a2f42c7";
	expect(self.tree.shortenedSha).to.equal(@"4c8f9ec");
}

@end