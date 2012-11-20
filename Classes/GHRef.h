#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHRef : GHResource

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSString *ref;
@property(nonatomic,retain)id object;

+ (id)refWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef;
- (id)initWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef;

@end