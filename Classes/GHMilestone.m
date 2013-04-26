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
	// Dynamic resourcePath, because it depends on the
	// number which isn't always available in advance
	return [NSString stringWithFormat:kMilestoneFormat, self.repository.owner, self.repository.name, self.number];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *login = [dict safeStringForKeyPath:@"creator.login"];
	self.creator = [iOctocat.sharedInstance userWithLogin:login];
	self.createdAt = [dict safeDateForKey:@"created_at"];
	self.dueAt = [dict safeDateForKey:@"due_at"];
	self.title = [dict safeStringForKey:@"title"];
	self.body = [dict safeStringForKey:@"description"];
	self.state = [dict safeStringForKey:@"state"];
	self.number = [dict safeIntegerForKey:@"number"];
}

#pragma mark Saving

- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = nil;
	NSString *method = nil;
	if (self.isNew) {
		path = [NSString stringWithFormat:kMilestonesFormat, self.repository.owner, self.repository.name];
		method = kRequestMethodPost;
	} else {
		path = [NSString stringWithFormat:kMilestoneFormat, self.repository.owner, self.repository.name, self.number];
		method = kRequestMethodPatch;
	}
	[self saveWithParams:params path:path method:method start:start success:^(GHResource *instance, id data) {
		[self setValues:data];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end
