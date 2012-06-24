#import <Foundation/Foundation.h>


@class GHUser;

@interface GHAccount : NSObject

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *token;
@property(nonatomic,retain)NSString *endpoint;
@property(nonatomic,retain)NSURL *endpointURL;
@property(nonatomic,retain)NSURL *apiURL;

+ (id)accountWithDict:(NSDictionary *)theDict;
- (id)initWithDict:(NSDictionary *)theDict;

@end
