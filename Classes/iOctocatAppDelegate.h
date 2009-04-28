#import <UIKit/UIKit.h>


@class GHUser;

@interface iOctocatAppDelegate : NSObject <UIApplicationDelegate> {
	NSMutableDictionary *users;
  @private
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	BOOL isDataSourceAvailable;
}

@property (nonatomic, readonly) BOOL isDataSourceAvailable;
@property (nonatomic, retain) NSMutableDictionary *users;

- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theUsername;

@end

