#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@interface GHIssueComment ()
@property(nonatomic,weak)id parent; // a GHIssue or GHPullRequest instance
@end

@implementation GHIssueComment

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
	[self saveValues:values withPath:path andMethod:kRequestMethodPost useResult:^(id response) {
		[self setValues:response];
	}];
}

@end