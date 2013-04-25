#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHMilestones : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithResourcePath:(NSString *)path;
- (id)initWithRepository:(GHRepository *)repo;
@end