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

- (NSString *)savePath {
	GHRepository *repo = [(GHIssue *)self.parent repository];
	NSUInteger num = [(GHIssue *)self.parent num];
	return [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
}

@end