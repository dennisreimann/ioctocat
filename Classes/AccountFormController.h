#import <UIKit/UIKit.h>


@class GradientButton;

@interface AccountFormController : UIViewController <UITextFieldDelegate>

@property(nonatomic,retain)NSMutableDictionary *account;
@property(nonatomic,retain)NSMutableArray *accounts;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,retain)IBOutlet UITextField *loginField;
@property(nonatomic,retain)IBOutlet UITextField *passwordField;
@property(nonatomic,retain)IBOutlet UITextField *tokenField;
@property(nonatomic,retain)IBOutlet UITextField *endpointField;
@property(nonatomic,retain)IBOutlet GradientButton *saveButton;

- (id)initWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex;
- (IBAction)saveAccount:(id)sender;

@end
