#import <UIKit/UIKit.h>


@interface LoginController : UIViewController <UITextFieldDelegate> {
  @private
	id target;
	SEL selector;
}

@property(nonatomic,retain)IBOutlet UITextField *loginField;
@property(nonatomic,retain)IBOutlet UITextField *passwordField;
@property(nonatomic,retain)IBOutlet UIButton *submitButton;

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;
- (IBAction)submit:(id)sender;
- (void)failWithMessage:(NSString *)theMessage;

@end
