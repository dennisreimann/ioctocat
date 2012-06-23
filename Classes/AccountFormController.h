#import <UIKit/UIKit.h>


@class GradientButton;

@interface AccountFormController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *loginField;
	IBOutlet UITextField *passwordField;
	IBOutlet UITextField *tokenField;
	IBOutlet UITextField *endpointField;
	IBOutlet GradientButton *saveButton;
}

- (id)initWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex;
- (IBAction)saveAccount:(id)sender;

@end
