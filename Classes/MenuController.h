@class GHUser;

@interface MenuController : UITableViewController
- (id)initWithUser:(GHUser *)user;
- (BOOL)openViewControllerForGitHubURL:(NSURL *)url;
@end