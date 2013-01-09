#import "IOCTestHelper.h"
#import "GHEventTests.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GHCommits.h"
#import "GHCommit.h"
#import "GHPullRequest.h"
#import "GHOrganization.h"


@interface GHEventTests ()
@property(nonatomic,strong)GHEvent *event;
@end


@implementation GHEventTests

- (void)setUp {
    [super setUp];
	self.event = [[GHEvent alloc] initWithDict:@{
		@"id": @"123",
		@"public": @1,
		@"created_at": @"2012-12-12T12:12:12Z",
		@"actor": @{
			@"login": @"testuser",
			@"avatar_url": @"https://gravatar.com/theuserurl"
		},
		@"org": @{
			@"login": @"testorg",
			@"avatar_url": @"https://gravatar.com/theorgurl"
		}
	}];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testReadState {
	expect(self.event.read).to.beFalsy();
}

- (void)testDate {
	expect(self.event.date).to.beKindOf(NSDate.class);
}

- (void)testUser {
	expect(self.event.user.login).to.equal(@"testuser");
	expect(self.event.user.gravatarURL).to.equal([NSURL URLWithString:@"https://gravatar.com/theuserurl"]);
}

- (void)testOrganization {
	expect(self.event.organization.login).to.equal(@"testorg");
	expect(self.event.organization.gravatarURL).to.equal([NSURL URLWithString:@"https://gravatar.com/theorgurl"]);
}

- (void)testIsCommentEvent {
	[self.event setValues:@{@"type": @"PullRequestReviewCommentEvent"}];
	expect(self.event.isCommentEvent).to.beTruthy();
	[self.event setValues:@{@"type": @"IssuesCommentEvent"}];
	expect(self.event.isCommentEvent).to.beTruthy();
	[self.event setValues:@{@"type": @"IssuesEvent"}];
	expect(self.event.isCommentEvent).to.beFalsy();
}

- (void)testExtendedEventType {
	[self.event setValues:@{@"type": @"IssuesEvent", @"payload": @{ @"action": @"closed" }}];
	expect(self.event.extendedEventType).to.equal(@"IssuesClosedEvent");
	
	[self.event setValues:@{@"type": @"IssuesEvent", @"payload": @{ @"action": @"open" }}];
	expect(self.event.extendedEventType).to.equal(@"IssuesOpenedEvent");
	
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"synchronize" }}];
	expect(self.event.extendedEventType).to.equal(@"PullRequestSynchronizeEvent");
	
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"closed" }}];
	expect(self.event.extendedEventType).to.equal(@"PullRequestClosedEvent");
	
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"open" }}];
	expect(self.event.extendedEventType).to.equal(@"PullRequestOpenedEvent");
}

- (void)testPullRequestReviewCommentEvent {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"PullRequestReviewCommentEvent"];
	[self.event setValues:dict];
	expect(self.event.pullRequest).notTo.beNil();
	expect(self.event.pullRequest.num).to.equal(194);
}

- (void)testIssueCommentEventWithoutPullRequest {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"IssueCommentEvent-WithoutPullRequest"];
	[self.event setValues:dict];
	expect(self.event.pullRequest).to.beNil();
}

- (void)testIssueCommentEventWithPullRequest {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"IssueCommentEvent-WithPullRequest"];
	[self.event setValues:dict];
	expect(self.event.pullRequest).notTo.beNil();
}

- (void)testCommitCommentEvent {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"CommitCommentEvent"];
	[self.event setValues:dict];
	expect(self.event.commits.count).to.equal(1);
	expect([(GHCommit *)self.event.commits[0] commitID]).to.equal(@"61b15830a1c7b8220bbe1fc8db67ce02a0df8bf0");
}

- (void)testPushEvent {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"PushEvent"];
	[self.event setValues:dict];
	expect(self.event.commits.count).to.equal(2);
	expect([(GHCommit *)self.event.commits[0] commitID]).to.equal(@"e365faf0207e64fbb373fc6690f54be2d8e4d2d9");
	expect([(GHCommit *)self.event.commits[0] message]).to.equal(@"Facebook API redirects to Facebook Login guide");
	expect([(GHCommit *)self.event.commits[1] commitID]).to.equal(@"f5cdeada37bf212593d8fda0da5f8d2e04b177e3");
	expect([(GHCommit *)self.event.commits[1] message]).to.equal(@"Merge pull request #187 from randomecho/linkrot");
}

@end