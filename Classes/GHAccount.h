#import <Foundation/Foundation.h>


@class GHApiClient, GHFeedClient, GHUser;

@interface GHAccount : NSObject

@property(nonatomic,retain)GHApiClient *apiClient;
@property(nonatomic,retain)GHFeedClient *feedClient;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *endpoint;
@property(nonatomic,retain)NSURL *endpointURL;
@property(nonatomic,retain)NSURL *apiURL;

+ (id)accountWithDict:(NSDictionary *)theDict;
- (id)initWithDict:(NSDictionary *)theDict;

@end
