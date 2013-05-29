#import "GHResource.h"


@class GHRepository, GHCommit, GHUser;

@interface GHBranch : GHResource
@property(nonatomic,strong)GHUser *author;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSURL *htmlURL;

- (id)initWithRepository:(GHRepository *)repo andName:(NSString *)name;
@end