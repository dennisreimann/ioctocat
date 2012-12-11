#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHGist, GHUser;

@interface GHGistComment : GHComment
- (id)initWithGist:(GHGist *)gist andDictionary:(NSDictionary *)dict;
- (id)initWithGist:(GHGist *)gist;
@end