#import "GHResource.h"


@class GHRepository;

@interface GHReadme : GHResource
@property(nonatomic,strong)NSString *bodyHTML;

- (id)initWithRepository:(GHRepository *)repo;
@end