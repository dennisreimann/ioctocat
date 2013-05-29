#import "GHCollection.h"


@class GHRepository;

@interface GHLabels : GHCollection
- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo;
@end