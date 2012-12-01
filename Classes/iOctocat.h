#import <UIKit/UIKit.h>
#import "AppConstants.h"


@class AccountController, GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject <UIApplicationDelegate>

@property(nonatomic,strong)GHAccount *currentAccount;
@property(nonatomic,strong)AccountController *accountController;
@property(nonatomic,strong)IBOutlet UIWindow *window;
@property(nonatomic,strong)IBOutlet UINavigationController *navController;

+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString;
+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString;
+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString;
+ (void)reportError:(NSString *)theTitle with:(NSString *)theMessage;
+ (void)reportLoadingError:(NSString *)theMessage;
+ (void)reportSuccess:(NSString *)theMessage;
- (BOOL)openURL:(NSURL *)url;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theLogin;
- (GHOrganization *)organizationWithLogin:(NSString *)theLogin;

@end