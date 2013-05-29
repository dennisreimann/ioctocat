@class GHOAuthClient, GHUserObjectsRepository, GHUser;

@interface GHAccount : NSObject <NSCoding>
@property(nonatomic,readonly)GHUserObjectsRepository *userObjects;
@property(nonatomic,strong)GHOAuthClient *apiClient;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *endpoint;
@property(nonatomic,strong)NSString *authToken;
@property(nonatomic,strong)NSString *pushToken;
@property(nonatomic,readonly)NSString *accountId;
@property(nonatomic,readonly)BOOL isGitHub;

- (id)initWithDict:(NSDictionary *)dict;
@end