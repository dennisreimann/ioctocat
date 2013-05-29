#import "GHCollection.h"


@class GHRepository;

@interface GHBranches : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)repo;
@end