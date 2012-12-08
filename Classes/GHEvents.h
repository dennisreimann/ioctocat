#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHEvents : GHResource

@property(nonatomic,strong)NSArray *events;
@property(nonatomic,strong)NSDate *lastReadingDate;

- (id)initWithRepository:(GHRepository *)theRepository;

@end