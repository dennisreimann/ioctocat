#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "MyFeedsController.h"
#import "GHUser.h"


@interface iOctocat : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
  @private
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet UIView *authView;
	IBOutlet MyFeedsController *feedController;
	UIActionSheet *authSheet;
	NSMutableDictionary *users;
	NSDate *lastLaunchDate;
	BOOL launchDefault;
}

@property(nonatomic,retain)NSMutableDictionary *users;
@property(nonatomic,retain)NSDate *lastLaunchDate;
@property(nonatomic,readonly)LoginController *loginController;

+ (id)sharedInstance;
- (GHUser *)currentUser;
- (UIView *)currentView ;
- (GHUser *)userWithLogin:(NSString *)theUsername;

@end

