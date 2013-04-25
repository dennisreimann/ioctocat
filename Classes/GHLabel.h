#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHLabel : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)UIColor *color;
@property(nonatomic,strong)NSString *hexColor;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSURL *apiURL;

- (id)initWithRepository:(GHRepository *)repo name:(NSString *)name;
- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end
