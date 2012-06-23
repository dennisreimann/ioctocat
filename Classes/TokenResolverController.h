#import <UIKit/UIKit.h>


@interface TokenResolverController : UIViewController <UIWebViewDelegate> {
  @private
	UIViewController *delegate;
	NSString *login;
	NSString *password;
}

- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)resolveForLogin:(NSString *)theLogin andPassword:(NSString *)thePassword;
@end

@protocol TokenResolverControllerDelegate
- (void)resolvedToken:(NSString *)theToken forLogin:(NSString *)theLogin;
@end
