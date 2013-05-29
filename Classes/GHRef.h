#import "GHResource.h"


@class GHRepository;

@interface GHRef : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *ref;
@property(nonatomic,strong)id object;

- (id)initWithRepo:(GHRepository *)repo andRef:(NSString *)ref;
@end