#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHUser;

@interface GHIssueComment : GHComment
- (id)initWithParent:(id)parent;
@end