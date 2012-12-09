#import <UIKit/UIKit.h>


@class ECSlidingViewController, GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject <UIApplicationDelegate>

@property(nonatomic,strong)GHAccount *currentAccount;
@property(nonatomic,strong)IBOutlet UIWindow *window;
@property(nonatomic,strong)IBOutlet UINavigationController *menuNavController;
@property(nonatomic,strong)IBOutlet ECSlidingViewController *slidingViewController;

+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString;
+ (void)reportError:(NSString *)theTitle with:(NSString *)theMessage;
+ (void)reportLoadingError:(NSString *)theMessage;
+ (void)reportSuccess:(NSString *)theMessage;
- (BOOL)openURL:(NSURL *)url;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theLogin;
- (GHOrganization *)organizationWithLogin:(NSString *)theLogin;

@end