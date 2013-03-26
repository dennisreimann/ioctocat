@interface IOCViewControllerFactory : NSObject
+ (UIViewController *)viewControllerForGitHubURL:(NSURL *)url;
@end