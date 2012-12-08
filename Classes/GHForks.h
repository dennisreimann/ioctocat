#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHForks : GHResource

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSArray *entries;

- (id)initWithRepository:(GHRepository *)theRepository;

@end