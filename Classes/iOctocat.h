#import <UIKit/UIKit.h>
#import "AppConstants.h"


@class ASINetworkQueue, AccountController, GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject <UIApplicationDelegate>

@property(nonatomic,retain)GHAccount *currentAccount;
@property(nonatomic,retain)AccountController *accountController;
@property(nonatomic,retain)IBOutlet UIWindow *window;
@property(nonatomic,retain)IBOutlet UINavigationController *navController;

+ (ASINetworkQueue *)queue;
+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString;
+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString;
+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString;
+ (void)reportError:(NSString *)theTitle with:(NSString *)theMessage;
+ (void)reportLoadingError:(NSString *)theMessage;
+ (void)reportSuccess:(NSString *)theMessage;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theLogin;
- (GHOrganization *)organizationWithLogin:(NSString *)theLogin;
										 
@end

