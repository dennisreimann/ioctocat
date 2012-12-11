#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "iOctocat.h"


@interface GHIssueComment ()
@property(nonatomic,weak)id parent; // a GHIssue or GHPullRequest instance
@end

@implementation GHIssueComment

- (id)initWithParent:(id)parent andDictionary:(NSDictionary *)dict {
	self = [self initWithParent:parent];
	if (self) {
		[self setUserWithValues:dict[@"user"]];
		self.body = dict[@"body"];
		self.created = [iOctocat parseDate:dict[@"created_at"]];
		self.updated = [iOctocat parseDate:dict[@"updated_at"]];
	}
	return self;
}

- (id)initWithParent:(id)parent {
	self = [super init];
	if (self) {
		self.parent = parent;
	}
	return self;
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = @{@"body": self.body};
	GHRepository *repo = [(GHIssue *)self.parent repository];
	NSUInteger num = [(GHIssue *)self.parent num];
	NSString *path = [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
	[self saveValues:values withPath:path andMethod:kRequestMethodPost useResult:nil];
}

@end