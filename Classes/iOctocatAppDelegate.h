#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "MyFeedsController.h"
#import "GHUser.h"


@interface iOctocatAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
  @private
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet MyFeedsController *feedController;
	IBOutlet UIActivityIndicatorView *activityView;
	UIActionSheet *authSheet;
	NSMutableDictionary *users;
	BOOL launchDefault;
}

@property (nonatomic, retain) NSMutableDictionary *users;
@property (nonatomic, readonly) LoginController *loginController;

- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theUsername;

@end

