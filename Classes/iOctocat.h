#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "AccountsController.h"
#import "AuthenticationController.h"
#import "ASINetworkQueue.h"


@class GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject <UIApplicationDelegate> {
	GHAccount *currentAccount;
}

@property(nonatomic,retain)GHAccount *currentAccount;
@property(nonatomic,retain)IBOutlet UINavigationController *accountsNavController;
@property(nonatomic,retain)IBOutlet UIWindow *window;

+ (ASINetworkQueue *)queue;
+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString;
+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString;
+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString;
+ (void)alert:(NSString *)theTitle with:(NSString *)theMessage;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theLogin;
- (GHOrganization *)organizationWithLogin:(NSString *)theLogin;
										 
@end

