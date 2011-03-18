#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "MyFeedsController.h"
#import "GHUser.h"
#import "ASINetworkQueue.h"


@interface iOctocat : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
  @private
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet UIView *authView;
	IBOutlet MyFeedsController *feedController;
	UIActionSheet *authSheet;
	NSMutableDictionary *users;
	NSDate *didBecomeActiveDate;
	BOOL launchDefault;
}

@property(nonatomic,retain)NSMutableDictionary *users;
@property(nonatomic,retain)NSDate *didBecomeActiveDate;
@property(nonatomic,readonly)LoginController *loginController;

+ (ASINetworkQueue *)queue;
+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString withFormat:(NSString *)theFormat;
- (GHUser *)currentUser;
- (UIView *)currentView;
- (GHUser *)userWithLogin:(NSString *)theUsername;
- (NSInteger)gravatarSize;
- (NSDate *)lastReadingDateForURL:(NSURL *)url;
- (void)setLastReadingDate:(NSDate *)date forURL:(NSURL *)url;
- (NSString *)cachedGravatarPathForIdentifier:(NSString *)theString;

@end

