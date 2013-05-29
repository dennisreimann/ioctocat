#import "GHCollection.h"


@class GHRepository;

@interface GHPullRequests : GHCollection
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *pullState;

- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo andState:(NSString *)state;
@end