#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHReadme : GHResource

@property(nonatomic,retain)NSString *bodyHTML;
@property(nonatomic,retain)GHRepository *repository;

+ (id)readmeWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end
