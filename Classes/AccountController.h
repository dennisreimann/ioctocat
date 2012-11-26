#import <UIKit/UIKit.h>


@class GHAccount;

@interface AccountController : UIViewController <UITabBarDelegate>

@property(nonatomic,strong)IBOutlet UITabBar *tabBar;
@property(nonatomic,strong)IBOutlet UITabBarItem *feedsTabBarItem;
@property(nonatomic,strong)IBOutlet UITabBarItem *reposTabBarItem;
@property(nonatomic,strong)IBOutlet UITabBarItem *profileTabBarItem;
@property(nonatomic,strong)IBOutlet UITabBarItem *issuesTabBarItem;
@property(nonatomic,strong)IBOutlet UITabBarItem *moreTabBarItem;

+ (id)controllerWithAccount:(GHAccount *)theAccount;
- (id)initWithAccount:(GHAccount *)theAccount;

@end