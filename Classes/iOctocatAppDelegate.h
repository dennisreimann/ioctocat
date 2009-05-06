#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "MyFeedsController.h"
#import "GHUser.h"


@interface iOctocatAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
  @private
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet UIView *authView;
	IBOutlet MyFeedsController *feedController;
	UIActionSheet *authSheet;
	NSMutableDictionary *users;
	BOOL launchDefault;
}

@property (nonatomic, retain) NSMutableDictionary *users;
@property (nonatomic, readonly) LoginController *loginController;

- (GHUser *)currentUser;
- (UIView *)currentView ;
- (GHUser *)userWithLogin:(NSString *)theUsername;

@end

