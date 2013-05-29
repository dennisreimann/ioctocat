#import "GHCollection.h"


@class GHGist;

@interface GHGistComments : GHCollection
- (id)initWithGist:(GHGist *)gist;
@end
