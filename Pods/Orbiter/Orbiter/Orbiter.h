// Orbiter.h
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

#import <Foundation/Foundation.h>

@interface Orbiter : NSObject

/**
 
 */
- (id)initWithBaseURL:(NSURL *)baseURL
           credential:(NSURLCredential *)credential;

/**
 
 */
- (NSURLRequest *)requestForRegistrationOfDeviceToken:(id)deviceToken
                                          withPayload:(NSDictionary *)payload;

/**
 
 */
- (NSURLRequest *)requestForUnregistrationOfDeviceToken:(id)deviceToken;

/**
 
 */
- (void)registerDeviceToken:(id)deviceToken
                  withAlias:(NSString *)alias
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)registerDeviceToken:(id)deviceToken
                withPayload:(NSDictionary *)payload
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)unregisterDeviceToken:(id)deviceToken
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure;
@end

#pragma mark -

@interface UrbanAirshipOrbiter : Orbiter

/**
 
 */
+ (UrbanAirshipOrbiter *)urbanAirshipManagerWithApplicationKey:(NSString *)key
                                             applicationSecret:(NSString *)secret;

/**
 
 */
- (void)registerDeviceToken:(id)deviceToken
                  withAlias:(NSString *)alias
                      badge:(NSNumber *)badge
                       tags:(NSSet *)tags
                   timeZone:(NSTimeZone *)timeZone
             quietTimeStart:(NSDateComponents *)quietTimeStartComponents
               quietTimeEnd:(NSDateComponents *)quietTimeEndComponents
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

@end

#pragma mark -

@interface ParseOrbiter : Orbiter

/**
 
 */
+ (ParseOrbiter *)parseManagerWithApplicationID:(NSString *)applicationID
                                     RESTAPIKey:(NSString *)RESTAPIKey;

/**
 
 */
- (void)registerDeviceToken:(id)deviceToken
                  withAlias:(NSString *)alias
                      badge:(NSNumber *)badge
                   channels:(NSSet *)tags
                   timeZone:(NSTimeZone *)timeZone
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

@end
