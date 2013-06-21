#import "GHMilestone.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHMilestone ()
@property(nonatomic,strong)NSString *bodyForDisplay;
@end


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

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:self.class] && [[object title] isEqualToString:self.title];
}

- (NSUInteger)hash {
	return [[self.title lowercaseString] hash];
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
    if (issuesTotal == 0) return 0;
    float percentPerIssue = 100.0f / issuesTotal;
    NSInteger percentDone = lroundf(self.closedIssueCount * percentPerIssue);
    return percentDone;
}

- (NSString *)bodyForDisplay {
    if (!_bodyForDisplay && self.body) {
        _bodyForDisplay = [self.body emojizedString];
    }
    return _bodyForDisplay;
}

- (void)setBody:(NSString *)body {
    _bodyForDisplay = nil;
    _body = body;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict ioc_stringForKeyPath:@"creator.login"];
	self.creator = [iOctocat.sharedInstance userWithLogin:login];
	self.number = [dict ioc_integerForKey:@"number"];
	self.title = [dict ioc_stringForKey:@"title"];
	self.state = [dict ioc_stringForKey:@"state"];
	self.body = [dict ioc_stringForKey:@"description"];
	self.dueOn = [dict ioc_dateForKey:@"due_on"];
	self.createdAt = [dict ioc_dateForKey:@"created_at"];
	self.openIssueCount = [dict ioc_integerForKey:@"open_issues"];
	self.closedIssueCount = [dict ioc_integerForKey:@"closed_issues"];
}

@end
