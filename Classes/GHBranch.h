#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHBranch : GHResource

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *sha;

+ (id)branchWithRepository:(GHRepository *)theRepository andName:(NSString *)theName;
- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName;

@end