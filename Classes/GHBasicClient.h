#import "AFNetworking.h"
#import "AFHTTPClient.h"


@interface GHBasicClient : AFHTTPClient
- (id)initWithEndpoint:(NSString *)endpoint username:(NSString *)username password:(NSString *)password;
- (void)saveAuthorizationWithNote:(NSString *)note scopes:(NSArray *)scopes success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
@end