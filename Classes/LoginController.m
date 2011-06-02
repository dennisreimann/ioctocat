#import "LoginController.h"
#import "NSString+Extensions.h"


@implementation LoginController

@synthesize loginField;
@synthesize passwordField;
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
	passwordField.text = [defaults valueForKey:kPasswordDefaultsKey];
	loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
	passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)dealloc {
	[loginField release], loginField = nil;
	[passwordField release], passwordField = nil;
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
	NSString *password = [passwordField.text stringByTrimmingCharactersInSet:trimSet];
	if ([login isEmpty] || [password isEmpty]) {
		[self failWithMessage:@"Please enter your login\nand password"];
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:login forKey:kLoginDefaultsKey];
		[defaults setValue:password forKey:kPasswordDefaultsKey];
		[defaults synchronize];
		submitButton.enabled = NO;
		[loginField resignFirstResponder];
		[passwordField resignFirstResponder];
		[target performSelector:selector];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[loginField resignFirstResponder];
	[passwordField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == loginField) [passwordField becomeFirstResponder];
	if (textField == passwordField) [self submit:nil];
	return YES;
}

@end
