#import "GHResource.h"
#import "GHRepository.h"
#import "GHNotification.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "NSDictionary+Extensions.h"


@interface GHNotification ()
@property(nonatomic,readwrite)BOOL read;
@end


@implementation GHNotification

- (id)initWithDict:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		self.read = NO;
		[self setValues:dict];
	}
	return self;
}

- (void)markAsRead {
	NSDictionary *values = @{@"read": @YES};
	[self saveValues:values withPath:self.resourcePath andMethod:kRequestMethodPatch useResult:^(id response) {
		[self setHeaderValues:values];
		self.read = YES;
	}];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSDictionary *repoDict = [dict safeDictForKey:@"repository"];
	NSString *owner = [repoDict safeStringForKeyPath:@"owner.login"];
	NSString *name = [repoDict safeStringForKey:@"name"];
	NSURL *subjectURL = [dict safeURLForKeyPath:@"subject.url"];
	self.notificationId = [dict safeIntegerForKey:@"id"];
	self.resourcePath = [NSString stringWithFormat:kNotificationThreadFormat, self.notificationId];
	self.updatedAtDate = [dict safeDateForKey:@"updated_at"];
	self.lastReadAtDate = [dict safeDateForKey:@"last_read_at"];
	self.read = [dict safeBoolForKey:@"unread"] ? ![dict safeBoolForKey:@"unread"] : NO;
	self.title = [dict safeStringForKeyPath:@"subject.title"];
	self.subjectType = [dict safeStringForKeyPath:@"subject.type"];
	self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
	[self.repository setValues:repoDict];
	if ([self.subjectType isEqualToString:@"PullRequest"]) {
		self.subject = [[GHPullRequest alloc] initWithRepository:self.repository];
		NSInteger num = [[subjectURL lastPathComponent] intValue];
		[(GHPullRequest *)self.subject setNum:num];
	} else if ([self.subjectType isEqualToString:@"Issue"]) {
		self.subject = [[GHIssue alloc] initWithRepository:self.repository];
		NSInteger num = [[subjectURL lastPathComponent] intValue];
		[(GHIssue *)self.subject setNum:num];
	} else if ([self.subjectType isEqualToString:@"Commit"]) {
		NSString *sha = [subjectURL lastPathComponent];
		self.subject = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	}
	if (self.subject) self.subject.resourcePath	= subjectURL.path;
}

@end
