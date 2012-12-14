#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository, GHCommit, GHUser;

@interface GHBranch : GHResource
@property(nonatomic,readonly)GHUser *author;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,strong)NSString *name;

- (id)initWithRepository:(GHRepository *)repo andName:(NSString *)name;
@end