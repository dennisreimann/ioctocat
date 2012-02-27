#import <UIKit/UIKit.h>


@class GHUser;
@class GradientButton;

@interface LoginController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	id delegate;
    GHUser *user;
  @private
    UIViewController *viewController;
	UIActionSheet *authSheet;
}

@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)GHUser *user;
@property(nonatomic,retain)IBOutlet UITextField *loginField;
@property(nonatomic,retain)IBOutlet UITextField *passwordField;
@property(nonatomic,retain)IBOutlet GradientButton *submitButton;

- (id)initWithViewController:(UIViewController *)theViewController;
- (IBAction)submit:(id)sender;
- (void)startAuthenticating;
- (void)stopAuthenticating;

@end

@protocol LoginControllerDelegate
- (void)finishedAuthenticating;
@end
