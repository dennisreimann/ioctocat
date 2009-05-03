#import <UIKit/UIKit.h>


@interface LoginController : UIViewController <UITextFieldDelegate> {
  @private
	id target;
	SEL selector;
	IBOutlet UITextField *loginField;
	IBOutlet UITextField *tokenField;
	IBOutlet UIButton *submitButton;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;
- (IBAction)submit:(id)sender;
- (void)failWithMessage:(NSString *)theMessage;

@end
