#import <Foundation/Foundation.h>


@class GHOAuthClient, GHUser;

@interface GHAccount : NSObject <NSCoding>
@property(nonatomic,strong)GHOAuthClient *apiClient;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *endpoint;
@property(nonatomic,strong)NSString *authId;
@property(nonatomic,strong)NSString *authToken;
@property(nonatomic,strong)NSString *pushToken;
@property(nonatomic,readonly)NSString *accountId;

- (id)initWithDict:(NSDictionary *)dict;
@end