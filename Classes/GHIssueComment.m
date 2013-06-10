#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "GHRepository.h"


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

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kIssueCommentsFormat, self.repository.owner, self.repository.name, [(GHIssue *)self.parent number]];
    } else {
        return [NSString stringWithFormat:kIssueCommentFormat, self.repository.owner, self.repository.name, self.commentID];
    }
}

- (GHRepository *)repository {
    return [(GHIssue *)self.parent repository];
}

@end