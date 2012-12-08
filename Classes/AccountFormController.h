#import <UIKit/UIKit.h>


@class GradientButton;

@interface AccountFormController : UIViewController <UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *loginField;
@property(nonatomic,weak)IBOutlet UITextField *passwordField;
@property(nonatomic,weak)IBOutlet UITextField *endpointField;
@property(nonatomic,weak)IBOutlet GradientButton *saveButton;

- (id)initWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex;
- (IBAction)saveAccount:(id)sender;
@end