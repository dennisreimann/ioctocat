#import <UIKit/UIKit.h>


@class GHAccount;

@interface AccountController : UIViewController <UITabBarDelegate>

@property(nonatomic,weak)IBOutlet UITabBar *tabBar;
@property(nonatomic,weak)IBOutlet UITabBarItem *feedsTabBarItem;
@property(nonatomic,weak)IBOutlet UITabBarItem *reposTabBarItem;
@property(nonatomic,weak)IBOutlet UITabBarItem *profileTabBarItem;
@property(nonatomic,weak)IBOutlet UITabBarItem *issuesTabBarItem;
@property(nonatomic,weak)IBOutlet UITabBarItem *moreTabBarItem;

+ (id)controllerWithAccount:(GHAccount *)theAccount;
- (id)initWithAccount:(GHAccount *)theAccount;

@end