#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHGist;

@interface GHGistComments : GHCollection
@property(nonatomic,strong)GHGist *gist;

- (id)initWithGist:(GHGist *)theGist;
@end
