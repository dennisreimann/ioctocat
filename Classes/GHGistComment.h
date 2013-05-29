#import "GHResource.h"
#import "GHComment.h"


@class GHGist;

@interface GHGistComment : GHComment
- (id)initWithGist:(GHGist *)gist;
@end