#import "GHResource.h"
#import "GHComment.h"


@class GHPullRequest;

@interface GHPullRequestReviewComment : GHComment
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,assign)NSUInteger position;
@property(nonatomic,assign)NSUInteger inReplyTo;
@property(nonatomic,readonly)GHPullRequest *parent;

- (id)initWithParent:(GHPullRequest *)parent;
@end