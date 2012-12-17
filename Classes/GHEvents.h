#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHRepository;

@interface GHEvents : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;

- (id)initWithRepository:(GHRepository *)repo;
@end