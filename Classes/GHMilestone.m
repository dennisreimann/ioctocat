#import "GHMilestone.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"


@implementation GHMilestone

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (BOOL)isNew {
	return !self.number ? YES : NO;
}

- (BOOL)isOpen {
	return [self.state isEqualToString:kIssueStateOpen];
}

- (NSString *)resourcePath {
	if (self.isNew) {
		return [NSString stringWithFormat:kMilestonesFormat, self.repository.owner, self.repository.name];
	} else {
        return [NSString stringWithFormat:kMilestoneFormat, self.repository.owner, self.repository.name, self.number];
	}
}

- (NSInteger)percentDone {
    NSInteger issuesTotal = self.openIssueCount + self.closedIssueCount;
    float percentPerIssue = 100.0f / issuesTotal;
    NSInteger percentDone = lroundf(self.closedIssueCount * percentPerIssue);
    return percentDone;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKeyPath:@"creator.login"];
	self.creator = [iOctocat.sharedInstance userWithLogin:login];
	self.number = [dict safeIntegerForKey:@"number"];
	self.title = [dict safeStringForKey:@"title"];
	self.state = [dict safeStringForKey:@"state"];
	self.body = [dict safeStringForKey:@"description"];
	self.dueOn = [dict safeDateForKey:@"due_on"];
	self.createdAt = [dict safeDateForKey:@"created_at"];
	self.openIssueCount = [dict safeIntegerForKey:@"open_issues"];
	self.closedIssueCount = [dict safeIntegerForKey:@"closed_issues"];
}

@end
