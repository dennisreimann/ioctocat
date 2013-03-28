#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHUser;

@interface GHIssueComment : GHComment
@property(nonatomic,readonly)id parent;
- (id)initWithParent:(id)parent;
@end