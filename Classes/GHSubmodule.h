#import "GHResource.h"


@class GHRepository, GHTree;

@interface GHSubmodule : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,readonly)GHTree *tree;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,readonly)NSString *shortenedSha;

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path sha:(NSString *)sha;
@end