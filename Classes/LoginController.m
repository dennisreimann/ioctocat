#import "LoginController.h"


@implementation LoginController

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super initWithNibName:@"Login" bundle:nil];
	target = theTarget;
	selector = theSelector;
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	loginField.text = [defaults valueForKey:kUsernameDefaultsKey];
	tokenField.text = [defaults valueForKey:kTokenDefaultsKey];
	loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
	tokenField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)failWithMessage:(NSString *)theMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication failed" message:theMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	submitButton.enabled = YES;
}

- (IBAction)submit:(id)sender {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *login = [loginField.text stringByTrimmingCharactersInSet:trimSet];
	NSString *token = [tokenField.text stringByTrimmingCharactersInSet:trimSet];
	if (![login isEqualToString:@""] && ![token isEqualToString:@""]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:login forKey:kUsernameDefaultsKey];
		[defaults setValue:token forKey:kTokenDefaultsKey];
		[defaults synchronize];
		submitButton.enabled = NO;
		[target performSelector:selector];
	} else {
		[self failWithMessage:@"Please enter your login\nand API token"];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[loginField resignFirstResponder];
	[tokenField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == loginField) [tokenField becomeFirstResponder];
	if (textField == tokenField) [self submit:nil];
	return YES;
}

- (void)dealloc {
	[loginField release];
	[tokenField release];
	[submitButton release];
    [super dealloc];
}

@end
