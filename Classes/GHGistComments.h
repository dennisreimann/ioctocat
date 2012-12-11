#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHGist;

@interface GHGistComments : GHCollection
- (id)initWithGist:(GHGist *)theGist;
@end
