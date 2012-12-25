#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHCommits : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)repo;
@end