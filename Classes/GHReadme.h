#import "GHBlob.h"


@class GHRepository;

@interface GHReadme : GHBlob
- (id)initWithRepository:(GHRepository *)repo;
@end