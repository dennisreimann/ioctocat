@class GHUser;

@interface MenuController : UITableViewController
@property(nonatomic,strong)UIViewController *initialViewController;

- (id)initWithUser:(GHUser *)user;
- (BOOL)openViewControllerForGitHubURL:(NSURL *)url;
- (void)openNotificationsController;
- (void)openNotificationControllerWithId:(NSInteger)notificationId url:(NSURL *)itemURL;
@end