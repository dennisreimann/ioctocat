#import <Foundation/Foundation.h>


@class GHApiClient, GHUser;

@interface GHAccount : NSObject <NSCoding>
@property(nonatomic,strong)GHApiClient *apiClient;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *endpoint;
@property(nonatomic,strong)NSString *authId;
@property(nonatomic,strong)NSString *authToken;
@property(nonatomic,assign)BOOL pushEnabled;

- (id)initWithDict:(NSDictionary *)dict;
@end