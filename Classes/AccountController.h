#import <UIKit/UIKit.h>


@class GHAccount;

@interface AccountController : UIViewController <UITabBarDelegate> {
	IBOutlet UITabBar *tabBar;
	IBOutlet UITabBarItem *feedsTabBarItem;
	IBOutlet UITabBarItem *reposTabBarItem;
	IBOutlet UITabBarItem *profileTabBarItem;
	IBOutlet UITabBarItem *moreTabBarItem;
	IBOutlet UITabBarItem *searchTabBarItem;
}

+ (id)controllerWithAccount:(GHAccount *)theAccount;
- (id)initWithAccount:(GHAccount *)theAccount;
										 
@end