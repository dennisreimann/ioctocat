#import <Foundation/Foundation.h>


@class GHApiClient, GHUser;

@interface GHAccount : NSObject
@property(nonatomic,strong)GHApiClient *apiClient;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)NSString *login;
@property(nonatomic,readonly)NSString *endpoint;

- (id)initWithDict:(NSDictionary *)dict;
@end