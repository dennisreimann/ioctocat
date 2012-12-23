@class GHUser;

@interface MenuController : UITableViewController
- (id)initWithUser:(GHUser *)user;
- (void)openViewControllerForGitHubURL:(NSURL *)url;
@end