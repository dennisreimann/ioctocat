#import <Foundation/Foundation.h>


@class GHApiClient, GHFeedClient, GHUser;

@interface GHAccount : NSObject

@property(nonatomic,strong)GHApiClient *apiClient;
@property(nonatomic,strong)GHFeedClient *feedClient;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *endpoint;
@property(nonatomic,strong)NSURL *endpointURL;
@property(nonatomic,strong)NSURL *apiURL;

- (id)initWithDict:(NSDictionary *)theDict;

@end