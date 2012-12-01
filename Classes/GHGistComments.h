#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHGist;

@interface GHGistComments : GHResource

@property(nonatomic,retain)NSMutableArray *comments;
@property(nonatomic,retain)GHGist *gist;

+ (id)commentsWithGist:(GHGist *)theGist;
- (id)initWithGist:(GHGist *)theGist;

@end
