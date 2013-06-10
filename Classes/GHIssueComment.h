#import "GHResource.h"
#import "GHComment.h"


@interface GHIssueComment : GHComment
@property(nonatomic,readonly)id parent;

- (id)initWithParent:(id)parent;
@end