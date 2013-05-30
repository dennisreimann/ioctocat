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
    expect(users.count).to.equal(1);
    NSDictionary *user = users[0];
    expect(user[@"title"]).to.equal(@"@user");
    expect(user[@"login"]).to.equal(@"user");
}

- (void)testGhfmarkdownUsernamesAtStringBounds {
    NSString *string = @"@user_1 and @user-2";
    NSArray *users = [string linksFromGHFMarkdownUsernames];
    expect(users.count).to.equal(2);
    NSDictionary *user1 = users[0];
    NSDictionary *user2 = users[1];
    expect(user1[@"title"]).to.equal(@"@user_1");
    expect(user1[@"login"]).to.equal(@"user_1");
    expect(user2[@"title"]).to.equal(@"@user-2");
    expect(user2[@"login"]).to.equal(@"user-2");
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

- (void)testGhfmarkdownShasWithContextRepoId {
    NSString *string = @"ed46435517b28c7112401a78d41d6ac16c999734 and dennisreimann/masq@16c999e8c71134401a78d4d46435517b2271d6ac and iosdeveloper@c71134401a78d4d464316c999e85517b2271d6ac.";
    NSArray *shas = [string linksFromGHFMarkdownWithContextRepoId:@"dennisreimann/ioctocat"];
    NSDictionary *sha1 = shas[0];
    NSDictionary *sha2 = shas[1];
    NSDictionary *sha3 = shas[2];
    expect(shas.count).to.equal(3);
    expect(sha1[@"title"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha1[@"sha"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha1[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/ioctocat/commit/ed46435517b28c7112401a78d41d6ac16c999734"]);
    expect(sha2[@"title"]).to.equal(@"dennisreimann/masq@16c999e8c71134401a78d4d46435517b2271d6ac");
    expect(sha2[@"sha"]).to.equal(@"16c999e8c71134401a78d4d46435517b2271d6ac");
    expect(sha2[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/masq/commit/16c999e8c71134401a78d4d46435517b2271d6ac"]);
    expect(sha3[@"title"]).to.equal(@"iosdeveloper@c71134401a78d4d464316c999e85517b2271d6ac");
    expect(sha3[@"sha"]).to.equal(@"c71134401a78d4d464316c999e85517b2271d6ac");
    expect(sha3[@"url"]).to.equal([NSURL URLWithString:@"/iosdeveloper/ioctocat/commit/c71134401a78d4d464316c999e85517b2271d6ac"]);
}

- (void)testGhfmarkdownShasWithoutContextRepoId {
    NSString *string = @"ed46435517b28c7112401a78d41d6ac16c999734 and no more";
    NSArray *shas = [string linksFromGHFMarkdownWithContextRepoId:nil];
    NSDictionary *sha = shas[0];
    expect(shas.count).to.equal(1);
    expect(sha[@"title"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha[@"sha"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha[@"url"]).to.beNil();
}

@end