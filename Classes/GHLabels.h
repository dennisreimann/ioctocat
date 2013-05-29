#import "GHCollection.h"


@class GHRepository;

@interface GHLabels : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo;
@end