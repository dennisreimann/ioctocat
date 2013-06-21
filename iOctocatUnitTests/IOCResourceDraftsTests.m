#import "IOCResourceDraftsTests.h"
#import "IOCResourceDrafts.h"


@implementation IOCResourceDraftsTest

- (void)tearDown {
    [super tearDown];
    [IOCResourceDrafts flush];
}

- (void)testDraftForKeyWithNoDraft {
	expect([IOCResourceDrafts draftForKey:@"https://github.com/dennisreimann/ioctocat/issues/313"]).to.beNil();
}

- (void)testDraftForKeyWithExistingDraft {
    NSDictionary *draft = @{@"title": @"My title", @"body": @"This is the issue body"};
    [IOCResourceDrafts saveDraft:draft forKey:@"https://github.com/dennisreimann/ioctocat/issues/313"];
	expect([IOCResourceDrafts draftForKey:@"https://github.com/dennisreimann/ioctocat/issues/313"]).to.equal(draft);
}

@end