@interface IOCViewControllerRepository : NSObject
+ (UIViewController *)viewControllerForGitHubURL:(NSURL *)url;
@end