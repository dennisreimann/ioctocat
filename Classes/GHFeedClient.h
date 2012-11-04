#import "AFNetworking.h"

@interface GHFeedClient : AFHTTPClient
+ (id)clientWithBaseURL:(NSURL *)url;
@end