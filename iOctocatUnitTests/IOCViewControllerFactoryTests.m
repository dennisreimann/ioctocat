#import "IOCViewControllerFactoryTests.h"
#import "IOCViewControllerFactory.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCIssuesController.h"
#import "IOCPullRequestController.h"
#import "IOCPullRequestsController.h"
#import "IOCGistController.h"
#import "IOCGistsController.h"
#import "IOCSearchController.h"
#import "IOCCommitsController.h"
#import "IOCCommitController.h"
#import "IOCTreeController.h"
#import "IOCBlobsController.h"
#import "IOCWebController.h"


@implementation IOCViewControllerFactoryTests

- (void)testWithUserURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/iOctocat"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCUserController.class);
}

- (void)testWithRepoURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCRepositoryController.class);
}

- (void)testWithReadmeURL {
	NSURL *url = [NSURL URLWithString:@"ioc://github.com/dennisreimann/ioctocat#attribution"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCWebController.class);
}

- (void)testWithSearchURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/search"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCSearchController.class);
}

- (void)testWithStaticURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/blog"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCWebController.class);
}

- (void)testWithGistsURL {
	NSURL *url = [NSURL URLWithString:@"https://gist.github.com/dennisreimann/"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCGistsController.class);
}

- (void)testWithGistURL {
	NSURL *url = [NSURL URLWithString:@"https://gist.github.com/dennisreimann/12345"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCGistController.class);
}

- (void)testWithIssuesURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/issues"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCIssuesController.class);
}

- (void)testWithIssueURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/issues/1"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCIssueController.class);
}

- (void)testWithPullRequestsURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/pull"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCPullRequestsController.class);
}

- (void)testWithPullRequestURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/pull/1"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCPullRequestController.class);
}

- (void)testWithCommitsURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/commits/master"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCCommitsController.class);
}

- (void)testWithCommitURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/commit/d9f318f1a575693e50e20495919a2817c327ab00"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCCommitController.class);
}

- (void)testWithTreeURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/tree/master/Classes"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCTreeController.class);
}

- (void)testWithBlobURL {
	NSURL *url = [NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat/blob/master/Classes/iOctocat.m"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCBlobsController.class);
}

- (void)testWithRelativeURL {
	NSURL *url = [NSURL URLWithString:@"/dennisreimann/ioctocat/blob/master/Classes/iOctocat.m"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCBlobsController.class);
}

- (void)testWithExternalURL {
	NSURL *url = [NSURL URLWithString:@"http://ioctocat.com"];
    id viewController = [IOCViewControllerFactory viewControllerForURL:url];
	expect(viewController).beKindOf(IOCWebController.class);
}

@end