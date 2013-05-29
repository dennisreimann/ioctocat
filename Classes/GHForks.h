#import "GHCollection.h"


@class GHRepository;

@interface GHForks : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)repo;
@end