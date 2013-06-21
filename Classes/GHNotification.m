#import "GHResource.h"
#import "GHRepository.h"
#import "GHNotification.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHNotification ()
@property(nonatomic,readwrite)BOOL read;
@end


@implementation GHNotification

- (id)initWithNotificationId:(NSInteger)notificationId {
	self = [super init];
	if (self) {
		self.notificationId = notificationId;
        self.resourcePath = [NSString stringWithFormat:kNotificationThreadFormat, self.notificationId];
	}
	return self;
}

- (id)initWithDict:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		self.read = NO;
		[self setValues:dict];
	}
	return self;
}

- (void)markAsReadStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	if (self.read) return;
	self.read = YES;
	NSDictionary *params = @{@"read": @YES};
	[self saveWithParams:params path:self.resourcePath method:kRequestMethodPatch start:start success:^(GHResource *notification, id data) {
		if (success) success(notification, data);
	} failure:^(GHResource *notification, NSError *error) {
		self.read = NO;
		if (failure) failure(notification, error);
	}];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSDictionary *repoDict = [dict ioc_dictForKey:@"repository"];
	NSString *owner = [repoDict ioc_stringForKeyPath:@"owner.login"];
	NSString *name = [repoDict ioc_stringForKey:@"name"];
	NSURL *subjectURL = [dict ioc_URLForKeyPath:@"subject.url"];
	self.notificationId = [dict ioc_integerForKey:@"id"];
	self.resourcePath = [NSString stringWithFormat:kNotificationThreadFormat, self.notificationId];
	self.updatedAt = [dict ioc_dateForKey:@"updated_at"];
	self.lastReadAt = [dict ioc_dateForKey:@"last_read_at"];
	self.read = [dict ioc_boolForKey:@"unread"] ? ![dict ioc_boolForKey:@"unread"] : NO;
	self.title = [dict ioc_stringForKeyPath:@"subject.title"];
	self.subjectType = [dict ioc_stringForKeyPath:@"subject.type"];
	self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
	[self.repository setValues:repoDict];
	if ([self.subjectType isEqualToString:@"PullRequest"]) {
		GHPullRequest *pullRequest = [[GHPullRequest alloc] initWithRepository:self.repository];
		pullRequest.number = [[subjectURL lastPathComponent] intValue];
		pullRequest.title = self.title;
		self.subject = pullRequest;
	} else if ([self.subjectType isEqualToString:@"Issue"]) {
		GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
		issue.number = [[subjectURL lastPathComponent] intValue];
		issue.title = self.title;
		self.subject = issue;
	} else if ([self.subjectType isEqualToString:@"Commit"]) {
		NSString *sha = [subjectURL lastPathComponent];
		GHCommit *commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
		commit.message = self.title;
		self.subject = commit;
	}
	if (self.subject) self.subject.resourcePath	= subjectURL.path;
}

@end
