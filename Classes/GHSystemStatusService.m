#import "GHSystemStatusService.h"
#import "GHOAuthClient.h"
#import "GHOAuthClient.h"
#import "NSDictionary_IOCExtensions.h"
#import "NSDate_IOCExtensions.h"


@implementation GHSystemStatusService

+ (void)checkWithMajor:(void (^)(NSString *message))onMajor minor:(void (^)(NSString *message))onMinor good:(void (^)(NSString *message))onGood failure:(void (^)(NSError *error))onFailure {
	NSURL *apiURL = [NSURL URLWithString:@"https://status.github.com/"];
	NSString *path = @"/api/last-message.json";
	NSString *method = kRequestMethodGet;
	GHOAuthClient *apiClient = [[GHOAuthClient alloc] initWithBaseURL:apiURL];
	NSMutableURLRequest *request = [apiClient requestWithMethod:method path:path parameters:nil];
	D3JLog(@"System status request: %@ %@", method, path);
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		D3JLog(@"System status request finished: %@", json);
		NSString *status = [json ioc_stringForKey:@"status"];
        NSString *date = [[json ioc_dateForKey:@"created_on"] ioc_prettyDate];
        NSString *body = [json ioc_stringForKey:@"body"];
        NSString *message = [NSString stringWithFormat:@"%@: %@", date, body];
        if ([status isEqualToString:@"major"] && onMajor) {
            onMajor(message);
        } else if ([status isEqualToString:@"minor"] && onMinor) {
            onMinor(message);
        } else if ([status isEqualToString:@"good"] && onGood) {
            onGood(message);
        }
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		D3JLog(@"System status request failed: %@", error);
        if (onFailure) onFailure(error);
	}];
	[operation start];
}

@end