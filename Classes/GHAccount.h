#import <Foundation/Foundation.h>


@class GHApiClient, GHUser;

@interface GHAccount : NSObject
@property(nonatomic,strong)GHApiClient *apiClient;
@property(nonatomic,strong)GHUser *user;

- (id)initWithDict:(NSDictionary *)dict;
@end