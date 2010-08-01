#import "LoginController.h"
#import "NSString+Extensions.h"


@implementation LoginController

@synthesize loginField;
@synthesize tokenField;
@synthesize submitButton;

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super initWithNibName:@"Login" bundle:nil];
	target = theTarget;
	selector = theSelector;
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	loginField.text = [defaults valueForKey:kLoginDefaultsKey];
	tokenField.text = [defaults valueForKey:kTokenDefaultsKey];
	loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
	tokenField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)dealloc {
	[loginField release], loginField = nil;
	[tokenField release], tokenField = nil;
	[submitButton release], submitButton = nil;
    [super dealloc];
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
	if ([login isEmpty] || [token isEmpty]) {
		[self failWithMessage:@"Please enter your login\nand API token"];
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:login forKey:kLoginDefaultsKey];
		[defaults setValue:token forKey:kTokenDefaultsKey];
		[defaults synchronize];
		submitButton.enabled = NO;
		[loginField resignFirstResponder];
		[tokenField resignFirstResponder];
		[target performSelector:selector];
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

@end
