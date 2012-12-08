#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHGist;

@interface GHGistComments : GHResource

@property(nonatomic,strong)NSMutableArray *comments;
@property(nonatomic,strong)GHGist *gist;

- (id)initWithGist:(GHGist *)theGist;

@end
