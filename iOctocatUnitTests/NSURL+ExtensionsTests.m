#import "NSURL+ExtensionsTests.h"
#import "NSURL+Extensions.h"


@implementation NSURL_ExtensionsTests

- (void)testIsGitHubURL {
    expect([[NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"http://github.com/dennisreimann/ioctocat"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"github.com/dennisreimann/ioctocat"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"/dennisreimann/ioctocat"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"/"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"https://gist.github.com/"] isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"http://ioctocat.com/"] isGitHubURL]).to.beFalsy();
    expect([[NSURL URLWithString:@"itms-services://?action=download"] isGitHubURL]).to.beFalsy();
}

@end