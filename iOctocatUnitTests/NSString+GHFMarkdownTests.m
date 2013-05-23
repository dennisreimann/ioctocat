#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSString+GHFMarkdownTests.h"
#import "NSString+GHFMarkdown.h"


@implementation NSString_GHFMarkdownTests

- (void)testGhfmarkdownLinks {
    NSString *string = @"This [is a link](http://ioctocat.com) and this ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png).";
    NSArray *links = [string linksFromGHFMarkdownLinks];
    NSDictionary *link = links[0];
    NSDictionary *image = links[1];
    expect(links.count).to.equal(2);
    expect(link[@"title"]).to.equal(@"is a link");
    expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
    expect(image[@"title"]).to.equal(@"an image");
    expect(image[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

- (void)testGhfmarkdownLinksAtStringBounds {
    NSString *string = @"[Link at start](http://ioctocat.com) and an ![image at the end](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)";
    NSArray *links = [string linksFromGHFMarkdownLinks];
    NSDictionary *link = links[0];
    NSDictionary *image = links[1];
    expect(links.count).to.equal(2);
    expect(link[@"title"]).to.equal(@"Link at start");
    expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
    expect(image[@"title"]).to.equal(@"image at the end");
    expect(image[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

- (void)testGhfmarkdownUsernames {
    NSString *string = @"This is an @user reference";
    NSArray *users = [string linksFromGHFMarkdownUsernames];
    NSDictionary *user = users[0];
    expect(users.count).to.equal(1);
    expect(user[@"title"]).to.equal(@"@user");
    expect(user[@"login"]).to.equal(@"user");
}

- (void)testGhfmarkdownIssuesWithContextRepoId {
    NSString *string = @"This is an #123 issue reference and here's a full dennisreimann/ioctocat#456 reference.";
    NSArray *issues = [string linksFromGHFMarkdownWithContextRepoId:@"dennisreimann/masq"];
    NSDictionary *issue1 = issues[0];
    NSDictionary *issue2 = issues[1];
    expect(issues.count).to.equal(2);
    expect(issue1[@"title"]).to.equal(@"#123");
    expect(issue1[@"number"]).to.equal(@"123");
    expect(issue1[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/masq/issues/123"]);
    expect(issue2[@"title"]).to.equal(@"dennisreimann/ioctocat#456");
    expect(issue2[@"number"]).to.equal(@"456");
    expect(issue2[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/ioctocat/issues/456"]);
}

- (void)testGhfmarkdownIssuesWithoutContextRepoId {
    NSString *string = @"This is an #123 issue reference.";
    NSArray *issues = [string linksFromGHFMarkdownWithContextRepoId:nil];
    NSDictionary *issue = issues[0];
    expect(issues.count).to.equal(1);
    expect(issue[@"title"]).to.equal(@"#123");
    expect(issue[@"number"]).to.equal(@"123");
    expect(issue[@"url"]).to.beNil();
}

@end