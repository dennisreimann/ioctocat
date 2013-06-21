#import "GHPullRequestReviewComment.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


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
	self.inReplyTo = [dict ioc_integerForKey:@"in_reply_to"];
	self.commitID = [dict ioc_stringForKey:@"commit_id"];
	self.position = [dict ioc_integerForKey:@"position"];
	self.path = [dict ioc_stringForKey:@"path"];
}

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kGHPullRequestCommentFormat, self.parent.repository.owner, self.parent.repository.name, self.parent.number];
    } else {
        return [NSString stringWithFormat:kGHPullRequestCommentFormat, self.parent.repository.owner, self.parent.repository.name, self.commentID];
    }
}

@end