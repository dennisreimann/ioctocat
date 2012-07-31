#import <UIKit/UIKit.h>


@interface TokenResolverController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
  @private
	UIViewController *delegate;
	UIActionSheet *resolveSheet;
	NSString *login;
	NSString *password;
	NSUInteger loginAttempts;
}

- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)resolveForLogin:(NSString *)theLogin andPassword:(NSString *)thePassword;
- (void)stopResolving;
@end

@protocol TokenResolverControllerDelegate
- (void)resolvedToken:(NSString *)theToken forLogin:(NSString *)theLogin;
@end
