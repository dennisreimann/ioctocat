#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHRef : GHResource

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *ref;
@property(nonatomic,strong)id object;

+ (id)refWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef;
- (id)initWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef;

@end