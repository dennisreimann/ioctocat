#import "GHPullRequestReviewComment.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"


@interface GHPullRequestReviewComment ()
@property(nonatomic,weak)GHPullRequest *parent;
@end

@implementation GHPullRequestReviewComment

- (id)initWithParent:(id)parent {
	self = [super init];
	if (self) {
		self.parent = parent;
	}
	return self;
}

- (void)setValues:(id)dict {
	[super setValues:dict];
	self.inReplyTo = [dict safeIntegerForKey:@"in_reply_to"];
	self.commitID = [dict safeStringForKey:@"commit_id"];
	self.position = [dict safeIntegerForKey:@"position"];
	self.path = [dict safeStringForKey:@"path"];
}

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kGHPullRequestCommentFormat, self.parent.repository.owner, self.parent.repository.name, self.parent.number];
    } else {
        return [NSString stringWithFormat:kGHPullRequestCommentFormat, self.parent.repository.owner, self.parent.repository.name, self.commentID];
    }
}

@end