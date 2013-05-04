#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHSubmodule : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *name;

- (id)initWithRepo:(GHRepository *)repo sha:(NSString *)sha;
@end