// Orbiter.m
// 
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Orbiter.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

static NSString * AFNormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@interface Orbiter ()
@property (readwrite, nonatomic, strong) AFHTTPClient *HTTPClient;
@end

@implementation Orbiter
@synthesize HTTPClient = _HTTPClient;

#ifdef __CORELOCATION__
+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([CLLocationManager locationServicesEnabled]) {
            _sharedLocationManager = [[CLLocationManager alloc] init];
            _sharedLocationManager.purpose = NSLocalizedStringFromTable(@"This application uses your current location to send targeted push notifications.", @"Orbiter", nil);
            _sharedLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            [_sharedLocationManager startUpdatingLocation];
        }
    });
    
    return _sharedLocationManager;
}
#endif

- (id)initWithBaseURL:(NSURL *)baseURL
           credential:(NSURLCredential *)credential
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.HTTPClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
    [self.HTTPClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    if (credential) {
        [self.HTTPClient setAuthorizationHeaderWithUsername:credential.user password:credential.password];
    }
    
    return self;
}

- (NSURLRequest *)requestForRegistrationOfDeviceToken:(id)deviceToken
                                          withPayload:(NSDictionary *)payload
{    
    return [self.HTTPClient requestWithMethod:@"PUT" path:[NSString stringWithFormat:@"devices/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:payload];
}

- (NSURLRequest *)requestForUnregistrationOfDeviceToken:(id)deviceToken {
    return [self.HTTPClient requestWithMethod:@"DELETE" path:[NSString stringWithFormat:@"devices/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:nil];
}

#pragma mark -

- (void)registerDeviceToken:(NSString *)deviceToken
                  withAlias:(NSString *)alias
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
    [mutablePayload setValue:[[NSLocale currentLocale] identifier] forKey:@"locale"];
    [mutablePayload setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"language"];
    [mutablePayload setValue:[[NSTimeZone defaultTimeZone] name] forKey:@"timezone"];
    
#ifdef __CORELOCATION__
    CLLocation *location = [[[self class] sharedLocationManager] location];
    if (location) {
        [mutablePayload setValue:[[NSNumber numberWithDouble:location.coordinate.latitude] stringValue] forKey:@"lat"];
        [mutablePayload setValue:[[NSNumber numberWithDouble:location.coordinate.longitude] stringValue] forKey:@"lng"];
    }
#endif
    
    NSMutableSet *mutableTags = [NSMutableSet set];
    [mutableTags addObject:[NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [mutableTags addObject:[[UIDevice currentDevice] model]];
    [mutableTags addObject:[NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]]];
    [mutablePayload setValue:[mutableTags allObjects] forKey:@"tags"];
    
    if (alias) {
        [mutablePayload setValue:alias forKey:@"alias"];
    }
    
    [self registerDeviceToken:deviceToken withPayload:mutablePayload success:success failure:failure];
}

- (void)registerDeviceToken:(NSString *)deviceToken
                withPayload:(NSDictionary *)payload
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self requestForRegistrationOfDeviceToken:deviceToken withPayload:payload];
    AFHTTPRequestOperation *operation = [self.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self.HTTPClient enqueueHTTPRequestOperation:operation];
}

- (void)unregisterDeviceToken:(NSString *)deviceToken
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [self requestForUnregistrationOfDeviceToken:deviceToken];
    AFHTTPRequestOperation *operation = [self.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self.HTTPClient enqueueHTTPRequestOperation:operation];
}

@end

#pragma mark -

static NSString * const kUrbanAirshipAPIBaseURLString = @"https://go.urbanairship.com/api/";

@implementation UrbanAirshipOrbiter

+ (Orbiter *)urbanAirshipManagerWithApplicationKey:(NSString *)key
                                   applicationSecret:(NSString *)secret
{
    return [[UrbanAirshipOrbiter alloc] initWithBaseURL:[NSURL URLWithString:kUrbanAirshipAPIBaseURLString] credential:[NSURLCredential credentialWithUser:key password:secret persistence:NSURLCredentialPersistenceForSession]];
}

#pragma mark - Orbiter

- (NSURLRequest *)requestForRegistrationOfDeviceToken:(id)deviceToken
                                          withPayload:(NSDictionary *)payload
{
    return [self.HTTPClient requestWithMethod:@"PUT" path:[NSString stringWithFormat:@"device_tokens/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:payload];
}

- (NSURLRequest *)requestForUnregistrationOfDeviceToken:(id)deviceToken {
    return [self.HTTPClient requestWithMethod:@"DELETE" path:[NSString stringWithFormat:@"device_tokens/%@", AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken)] parameters:nil];
}

- (void)registerDeviceToken:(NSString *)deviceToken
                  withAlias:(NSString *)alias
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure
{
    [self registerDeviceToken:deviceToken withAlias:alias badge:nil tags:nil timeZone:[NSTimeZone defaultTimeZone] quietTimeStart:nil quietTimeEnd:nil success:success failure:failure];
}

- (void)registerDeviceToken:(NSString *)deviceToken
                  withAlias:(NSString *)alias
                      badge:(NSNumber *)badge
                       tags:(NSSet *)tags
                   timeZone:(NSTimeZone *)timeZone
             quietTimeStart:(NSDateComponents *)quietTimeStartComponents
               quietTimeEnd:(NSDateComponents *)quietTimeEndComponents
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
    if (alias) {
        [mutablePayload setValue:alias forKey:@"alias"];
    }
    
    if (badge) {
        [mutablePayload setValue:[badge stringValue] forKey:@"badge"];
    }
    
    if (tags && [tags count] > 0) {
        [mutablePayload setValue:[tags allObjects] forKey:@"tags"];
    }
    
    if (quietTimeStartComponents && quietTimeEndComponents) {
        NSMutableDictionary *mutableQuietTimePayload = [NSMutableDictionary dictionary];
        [mutableQuietTimePayload setValue:[NSString stringWithFormat:@"%02d:%02d", [quietTimeStartComponents hour], [quietTimeStartComponents minute]] forKey:@"start"];
        [mutableQuietTimePayload setValue:[NSString stringWithFormat:@"%02d:%02d", [quietTimeEndComponents hour], [quietTimeEndComponents minute]] forKey:@"end"];
        
        [mutablePayload setValue:mutableQuietTimePayload forKey:@"quiettime"];
    }
    
    if (timeZone) {
        [mutablePayload setValue:[timeZone name] forKey:@"tz"];
    }
    
    [self registerDeviceToken:deviceToken withPayload:mutablePayload success:success failure:failure];
}

@end

#pragma mark -

static NSString * const kParseAPIBaseURLString = @"https://api.parse.com/1/";

@implementation ParseOrbiter

+ (Orbiter *)parseManagerWithApplicationID:(NSString *)applicationID
                                  RESTAPIKey:(NSString *)RESTAPIKey
{
    ParseOrbiter *orbiter = [[ParseOrbiter alloc] initWithBaseURL:[NSURL URLWithString:kParseAPIBaseURLString] credential:nil];
    [orbiter.HTTPClient setDefaultHeader:@"X-Parse-Application-Id" value:applicationID];
    [orbiter.HTTPClient setDefaultHeader:@"X-Parse-REST-API-Key" value:RESTAPIKey];
    
    return orbiter;
}

#pragma mark - Orbiter

- (NSURLRequest *)requestForRegistrationOfDeviceToken:(id)deviceToken
                                          withPayload:(NSDictionary *)payload
{
    return [self.HTTPClient requestWithMethod:@"POST" path:@"installations" parameters:payload];
}

- (NSURLRequest *)requestForUnregistrationOfDeviceToken:(id)deviceToken {
    return nil;
}


- (void)registerDeviceToken:(id)deviceToken
                  withAlias:(NSString *)alias
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure
{
    [self registerDeviceToken:deviceToken withAlias:alias badge:nil channels:nil timeZone:[NSTimeZone defaultTimeZone] success:success failure:failure];
}

- (void)registerDeviceToken:(id)deviceToken
                  withAlias:(NSString *)alias
                      badge:(NSNumber *)badge
                   channels:(NSSet *)channels
                   timeZone:(NSTimeZone *)timeZone
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
    [mutablePayload setValue:@"ios" forKey:@"deviceType"];
    [mutablePayload setValue:AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken) forKey:@"deviceToken"];
    
    if (alias) {
        [mutablePayload setValue:alias forKey:@"alias"];
    }
    
    if (badge) {
        [mutablePayload setValue:[badge stringValue] forKey:@"badge"];
    }
    
    if (channels && [channels count] > 0) {
        [mutablePayload setValue:[channels allObjects] forKey:@"channels"];
    }
    
    if (timeZone) {
        [mutablePayload setValue:[timeZone name] forKey:@"tz"];
    }
    
    [self registerDeviceToken:deviceToken withPayload:mutablePayload success:success failure:failure];
}

- (void)unregisterDeviceToken:(id)deviceToken
                      success:(void (^)())success
                      failure:(void (^)(NSError *))failure
{
    [NSException raise:@"Unregistraion not supported by Parse API" format:nil];
}

@end
