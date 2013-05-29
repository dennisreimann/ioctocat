#import "GHCollection.h"


@class GHRepository;

@interface GHIssues : GHCollection
- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo andState:(NSString *)state;
@end