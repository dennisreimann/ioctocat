#import "IOCTestHelper.h"
#import "GHEventTests.h"
#import "GHEvent.h"
#import "GHUser.h"
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
	STAssertFalse(self.event.read, @"Event was initialized as read");
}

- (void)testDate {
	STAssertTrue([self.event.date isKindOfClass:NSDate.class], @"Date is not a NSDate instance");
}

- (void)testUser {
	STAssertEqualObjects(@"testuser", self.event.user.login, @"User login is not correct");
	STAssertEqualObjects([NSURL URLWithString:@"https://gravatar.com/theuserurl"], self.event.user.gravatarURL, @"User gravatar URL is not correct");
}

- (void)testOrganization {
	STAssertEqualObjects(@"testorg", self.event.organization.login, @"Organization login is not correct");
	STAssertEqualObjects([NSURL URLWithString:@"https://gravatar.com/theorgurl"], self.event.organization.gravatarURL, @"Organization gravatar URL is not correct");
}

- (void)testIsCommentEvent {
	[self.event setValues:@{@"type": @"IssuesCommentEvent"}];
	STAssertTrue(self.event.isCommentEvent, @"IssuesCommentEvent is not flagged as comment event");
	[self.event setValues:@{@"type": @"IssuesEvent"}];
	STAssertFalse(self.event.isCommentEvent, @"IssuesEvent is flagged as comment event");
}

- (void)testExtendedEventType {
	[self.event setValues:@{@"type": @"IssuesEvent", @"payload": @{ @"action": @"closed" }}];
	STAssertEqualObjects(@"IssuesClosedEvent", self.event.extendedEventType, @"IssuesEvent event type was not extended correctly");
	[self.event setValues:@{@"type": @"IssuesEvent", @"payload": @{ @"action": @"open" }}];
	STAssertEqualObjects(@"IssuesOpenedEvent", self.event.extendedEventType, @"IssuesEvent event type was not extended correctly");
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"synchronize" }}];
	STAssertEqualObjects(@"PullRequestSynchronizeEvent", self.event.extendedEventType, @"PullRequestEvent event type was not extended correctly");
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"closed" }}];
	STAssertEqualObjects(@"PullRequestClosedEvent", self.event.extendedEventType, @"PullRequestEvent event type was not extended correctly");
	[self.event setValues:@{@"type": @"PullRequestEvent", @"payload": @{ @"action": @"open" }}];
	STAssertEqualObjects(@"PullRequestOpenedEvent", self.event.extendedEventType, @"PullRequestEvent event type was not extended correctly");
}

- (void)testIssueCommentEventWithoutPullRequest {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"IssueCommentEventWithoutPullRequest"];
	[self.event setValues:dict];
	STAssertNil(self.event.pullRequest, @"Pull Request was set on an IssueCommentEvent without a pull request");
}

- (void)testIssueCommentEventWithPullRequest {
	NSDictionary *dict = [IOCTestHelper jsonFixture:@"IssueCommentEventWithPullRequest"];
	[self.event setValues:dict];
	STAssertNotNil(self.event.pullRequest, @"Pull Request was not set on an IssueCommentEvent with a pull request");
}

@end