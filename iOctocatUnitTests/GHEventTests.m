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

@end