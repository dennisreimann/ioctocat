#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHBranches : GHResource

@property(nonatomic,strong)NSMutableArray *branches;
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;

@end