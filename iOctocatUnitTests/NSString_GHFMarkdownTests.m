#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSString_GHFMarkdownTests.h"
#import "GHFMarkdown.h"
#import "GHFMarkdown_Private.h"


@implementation NSString_GHFMarkdownTests

- (void)testGhfmarkdownLinks {
    NSString *string = @"This [is a link](http://ioctocat.com) and this text.";
    NSArray *links = [string ghf_linksFromGHFMarkdownLinks];
    expect(links.count).to.equal(1);
    NSDictionary *link = links[0];
    expect(link[@"title"]).to.equal(@"is a link");
    expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
}

- (void)testGhfmarkdownLinksAtStringBounds {
    NSString *string = @"[Link at start](http://ioctocat.com) and a [link at the end](https://github.com/)";
    NSArray *links = [string ghf_linksFromGHFMarkdownLinks];
    expect(links.count).to.equal(2);
    NSDictionary *link1 = links[0];
    NSDictionary *link2 = links[1];
    expect(link1[@"title"]).to.equal(@"Link at start");
    expect(link1[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
    expect(link2[@"title"]).to.equal(@"link at the end");
    expect(link2[@"url"]).to.equal([NSURL URLWithString:@"https://github.com/"]);
}

- (void)testGhfmarkdownImages {
    NSString *string = @"This is ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png).";
    NSArray *images = [string ghf_linksFromGHFMarkdownLinks];
    expect(images.count).to.equal(1);
    NSDictionary *image = images[0];
    expect(image[@"title"]).to.equal(@"an image");
    expect(image[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

- (void)testGhfmarkdownImagesAtStringBounds {
    NSString *string = @"![Image at start](http://ioctocat.com/img/iOctocat.png) and an ![image at the end](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)";
    NSArray *images = [string ghf_linksFromGHFMarkdownLinks];
    expect(images.count).to.equal(2);
    NSDictionary *img1 = images[0];
    NSDictionary *img2 = images[1];
    expect(img1[@"title"]).to.equal(@"Image at start");
    expect(img1[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat.png"]);
    expect(img2[@"title"]).to.equal(@"image at the end");
    expect(img2[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

- (void)testGhfmarkdownLinksAndImages {
    NSString *string = @"This [is a link](http://ioctocat.com) and this an ![image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png).";
    NSArray *links = [string ghf_linksFromGHFMarkdownLinks];
    expect(links.count).to.equal(2);
    NSDictionary *link = links[0];
    NSDictionary *image = links[1];
    expect(link[@"title"]).to.equal(@"is a link");
    expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
    expect(image[@"title"]).to.equal(@"image");
    expect(image[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

- (void)testGhfmarkdownUsernames {
    NSString *string = @"This is an @user reference";
    NSArray *users = [string ghf_linksFromGHFMarkdownUsernames];
    expect(users.count).to.equal(1);
    NSDictionary *user = users[0];
    expect(user[@"title"]).to.equal(@"@user");
    expect(user[@"login"]).to.equal(@"user");
}

- (void)testGhfmarkdownUsernamesAtStringBounds {
    NSString *string = @"@user_1 and @user-2";
    NSArray *users = [string ghf_linksFromGHFMarkdownUsernames];
    expect(users.count).to.equal(2);
    NSDictionary *user1 = users[0];
    NSDictionary *user2 = users[1];
    expect(user1[@"title"]).to.equal(@"@user_1");
    expect(user1[@"login"]).to.equal(@"user_1");
    expect(user2[@"title"]).to.equal(@"@user-2");
    expect(user2[@"login"]).to.equal(@"user-2");
}

- (void)testGhfmarkdownIssuesWithContextRepoId {
    NSString *string = @"This is an #123 issue reference and here's a full dennisreimann/masq#456 reference and iosdeveloper#789.";
    NSArray *issues = [string ghf_linksFromGHFMarkdownWithContextRepoId:@"dennisreimann/ioctocat"];
    expect(issues.count).to.equal(3);
    NSDictionary *issue1 = issues[0];
    NSDictionary *issue2 = issues[1];
    NSDictionary *issue3 = issues[2];
    expect(issue1[@"title"]).to.equal(@"#123");
    expect(issue1[@"number"]).to.equal(@"123");
    expect(issue1[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/ioctocat/issues/123"]);
    expect(issue2[@"title"]).to.equal(@"dennisreimann/masq#456");
    expect(issue2[@"number"]).to.equal(@"456");
    expect(issue2[@"url"]).to.equal([NSURL URLWithString:@"/dennisreimann/masq/issues/456"]);
    expect(issue3[@"title"]).to.equal(@"iosdeveloper#789");
    expect(issue3[@"number"]).to.equal(@"789");
    expect(issue3[@"url"]).to.equal([NSURL URLWithString:@"/iosdeveloper/ioctocat/issues/789"]);
}

- (void)testGhfmarkdownIssuesWithoutContextRepoId {
    NSString *string = @"This is an #123 issue reference.";
    NSArray *issues = [string ghf_linksFromGHFMarkdownWithContextRepoId:nil];
    expect(issues.count).to.equal(1);
    NSDictionary *issue = issues[0];
    expect(issue[@"title"]).to.equal(@"#123");
    expect(issue[@"number"]).to.equal(@"123");
    expect(issue[@"url"]).to.beNil();
}

- (void)testGhfmarkdownShasWithContextRepoId {
    NSString *string = @"ed46435517b28c7112401a78d41d6ac16c999734 and dennisreimann/masq@16c999e8c71134401a78d4d46435517b2271d6ac and iosdeveloper@c71134401a78d4d464316c999e85517b2271d6ac.";
    NSArray *shas = [string ghf_linksFromGHFMarkdownWithContextRepoId:@"dennisreimann/ioctocat"];
    expect(shas.count).to.equal(3);
    NSDictionary *sha1 = shas[0];
    NSDictionary *sha2 = shas[1];
    NSDictionary *sha3 = shas[2];
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
    NSArray *shas = [string ghf_linksFromGHFMarkdownWithContextRepoId:nil];
    expect(shas.count).to.equal(1);
    NSDictionary *sha = shas[0];
    expect(sha[@"title"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha[@"sha"]).to.equal(@"ed46435517b28c7112401a78d41d6ac16c999734");
    expect(sha[@"url"]).to.beNil();
}

- (void)testghf_linksFromGHFMarkdownWithContextRepoIdAndImagesInCodeBlocks {
    NSString *string = @"This is an #123 issue reference and this\n\n```\ncode block [has a link](http://ioctocat.com) and this is an ![image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)\n```\n\nwithin a code block.";
    NSArray *links = [string ghf_linksFromGHFMarkdownWithContextRepoId:@"dennisreimann/ioctocat"];
    expect(links.count).to.equal(1);
    NSDictionary *link = links[0];
    expect(link[@"title"]).to.equal(@"#123");
}

- (void)testGhfmarkdownHeadlines {
    NSString *string = @"Text\n\n# Headline\n\nMore Text";
    NSArray *headlines = [string ghf_headlinesFromGHFMarkdown];
    expect(headlines.count).to.equal(1);
    NSDictionary *head = headlines[0];
    expect(head[@"title"]).to.equal(@"Headline");
    expect(head[@"headline"]).to.equal(@"# Headline");
    expect(head[@"level"]).to.equal(1);
}

- (void)testGhfmarkdownHeadlinesAtStringBounds {
    NSString *string = @"# First Headline #\n\nText\n\n## Second Headline\n\nMore Text\n\n### Third Headline ###";
    NSArray *headlines = [string ghf_headlinesFromGHFMarkdown];
    expect(headlines.count).to.equal(3);
    NSDictionary *head1 = headlines[0];
    NSDictionary *head2 = headlines[1];
    NSDictionary *head3 = headlines[2];
    expect(head1[@"title"]).to.equal(@"First Headline");
    expect(head1[@"headline"]).to.equal(@"# First Headline #");
    expect(head1[@"level"]).to.equal(1);
    expect(head2[@"title"]).to.equal(@"Second Headline");
    expect(head2[@"headline"]).to.equal(@"## Second Headline");
    expect(head2[@"level"]).to.equal(2);
    expect(head3[@"title"]).to.equal(@"Third Headline");
    expect(head3[@"headline"]).to.equal(@"### Third Headline ###");
    expect(head3[@"level"]).to.equal(3);
}

@end