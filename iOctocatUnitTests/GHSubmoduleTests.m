#import "IOCTestHelper.h"
#import "GHSubmoduleTests.h"
#import "GHSubmodule.h"
#import "GHTree.h"
#import "GHRepository.h"


@interface GHSubmoduleTests ()
@property(nonatomic,strong)GHSubmodule *submodule;
@end


@implementation GHSubmoduleTests

- (void)setUp {
    [super setUp];
    GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
    self.submodule = [[GHSubmodule alloc] initWithRepo:repo path:@"Assets/highlight.js" sha:@"4c8f9eca94857c4647ea6988491c9cec0a2f42c7"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTree {
	expect(self.submodule.tree.ref).to.equal(@"4c8f9eca94857c4647ea6988491c9cec0a2f42c7");
	expect(self.submodule.tree.path).to.equal(@"");
}

- (void)testShortenedSHA {
	expect(self.submodule.shortenedSha).to.equal(@"4c8f9ec");
}

@end