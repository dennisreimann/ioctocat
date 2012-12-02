#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHReadme : GHResource

@property(nonatomic,strong)NSString *bodyHTML;
@property(nonatomic,strong)GHRepository *repository;

+ (id)readmeWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end