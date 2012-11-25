#import <UIKit/UIKit.h>


@class GradientButton;

@interface AccountFormController : UIViewController <UITextFieldDelegate>

@property(nonatomic,strong)IBOutlet UITextField *loginField;
@property(nonatomic,strong)IBOutlet UITextField *passwordField;
@property(nonatomic,strong)IBOutlet UITextField *endpointField;
@property(nonatomic,strong)IBOutlet GradientButton *saveButton;

+ (id)controllerWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex;
- (id)initWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex;
- (IBAction)saveAccount:(id)sender;

@end