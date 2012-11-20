#import "AFNetworking.h"


@interface GHApiClient : AFHTTPClient
+ (id)clientWithBaseURL:(NSURL *)url;
@end