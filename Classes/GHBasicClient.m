#import "GHBasicClient.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHBasicClient

- (id)initWithEndpoint:(NSString *)endpoint username:(NSString *)username password:(NSString *)password {
	// construct endpoint URL
	NSURL *url = (!endpoint || [endpoint ioc_isEmpty] || [endpoint isEqualToString:kGitHubComURL]) ?
        [NSURL URLWithString:kGitHubApiURL] :
        [[NSURL ioc_smartURLFromString:endpoint defaultScheme:@"https"] URLByAppendingPathComponent:kEnterpriseApiPath];
	// initialize
	self = [super initWithBaseURL:url];
	if (self) {
		NSSet *jsonTypes = [NSSet setWithObjects:
							kResourceContentTypeDefault,
							kResourceContentTypeText,
							kResourceContentTypeFull,
							kResourceContentTypeRaw, nil];
		[AFJSONRequestOperation addAcceptableContentTypes:jsonTypes];
		[self setDefaultHeader:@"Accept" value:kResourceContentTypeDefault];
		[self setParameterEncoding:AFJSONParameterEncoding];
		[self registerHTTPOperationClass:AFJSONRequestOperation.class];
		[self setAuthorizationHeaderWithUsername:username password:password];
	}
	return self;
}

#pragma mark Authorizations

// tries to find an existing authorization with the given note. the success
// callback is triggered in case an authorization could be found or there is
// not an authorization with the given note - the latter case returns nil.
// the failure callback gets triggered if there is an authentication error.
- (void)findAuthorizationWithNote:(NSString *)note success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = kAuthorizationsFormat;
	D3JLog(@"Find authorization: %@", note);
	[self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
		D3JLog(@"Finding authorization finished: %@", json);
		NSDictionary *existingAuth = nil;
		for (NSDictionary *auth in json) {
			NSString *authNote = [auth ioc_stringForKey:@"note"];
			if ([authNote isEqualToString:note]) {
				existingAuth = auth;
				break;
			}
		}
		if (success) success(existingAuth);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Finding authorization failed: %@", error);
		if (failure) failure(error);
	}];
}

// tries to find an existing authorization with the given note, so that an
// eventually existing one can be updated. it is important to look that up
// first, so that existing authorizations can be shared across the users
// devices, so that one does not have to create an authorization per device.
- (void)saveAuthorizationWithNote:(NSString *)note scopes:(NSArray *)scopes success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	[self findAuthorizationWithNote:note success:^(id json) {
		NSInteger authId = [json ioc_integerForKey:@"id"];
		NSString *path = authId ? [NSString stringWithFormat:kAuthorizationFormat, authId] : kAuthorizationsFormat;
		NSString *method = authId ? kRequestMethodPatch : kRequestMethodPost;
		NSDictionary *params = @{@"scopes": scopes, @"note": note, @"note_url": @"http://ioctocat.com"};
		NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:params];
		D3JLog(@"Save authorization: %@ (%@)\n\nData:\n%@\n", path, method, params);
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
			D3JLog(@"Saving authorization finished: %@", json);
			if (success) success(json);
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
			D3JLog(@"Saving authorization failed: %@", error);
			if (failure) failure(error);
		}];
		[operation start];
	} failure:^(NSError *error) {
		if (failure) failure(error);
	}];
}

@end