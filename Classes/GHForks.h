#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHForks : GHCollection
@property(nonatomic,strong)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository;
@end