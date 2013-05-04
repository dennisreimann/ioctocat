#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHTree : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *ref;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *mode;
@property(nonatomic,strong)NSMutableArray *trees;
@property(nonatomic,strong)NSMutableArray *blobs;

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path ref:(NSString*)ref;
@end