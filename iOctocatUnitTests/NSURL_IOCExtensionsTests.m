#import "NSURL_IOCExtensionsTests.h"
#import "NSURL_IOCExtensions.h"


@implementation NSURL_IOCExtensionsTests

- (void)testIsGitHubURL {
    expect([[NSURL URLWithString:@"https://github.com/dennisreimann/ioctocat"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"http://github.com/dennisreimann/ioctocat"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"github.com/dennisreimann/ioctocat"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"/dennisreimann/ioctocat"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"/"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"https://gist.github.com/"] ioc_isGitHubURL]).to.beTruthy();
    expect([[NSURL URLWithString:@"http://ioctocat.com/"] ioc_isGitHubURL]).to.beFalsy();
    expect([[NSURL URLWithString:@"itms-services://?action=download"] ioc_isGitHubURL]).to.beFalsy();
}

@end