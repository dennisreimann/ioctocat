#import "AccountFormController.h"
#import "AccountsController.h"
#import "GHAccount.h"
#import "GradientButton.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"


@interface AccountFormController ()
@property(nonatomic,retain)NSMutableDictionary *account;
@property(nonatomic,retain)NSMutableArray *accounts;
@property(nonatomic,assign)NSUInteger index;
@end


@implementation AccountFormController

+ (id)controllerWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex {
	return [[[self.class alloc] initWithAccounts:theAccounts andIndex:theIndex] autorelease];
}

- (id)initWithAccounts:(NSMutableArray *)theAccounts andIndex:(NSUInteger)theIndex {
    self = [super initWithNibName:@"AccountForm" bundle:nil];
	if (self) {
		self.index = theIndex;
		self.accounts = theAccounts;
		// Find existing or initialize a new account
		if (self.index == NSNotFound) {
			self.account = [NSMutableDictionary dictionary];
		} else {
			self.account = [self.accounts objectAtIndex:self.index];
		}
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Account", self.index == NSNotFound ? @"New" : @"Edit"];
	self.loginField.text = [self.account valueForKey:kLoginDefaultsKey];
	self.passwordField.text = [self.account valueForKey:kPasswordDefaultsKey];
	self.endpointField.text = [self.account valueForKey:kEndpointDefaultsKey];
}

- (void)dealloc {
	[_account release], _account = nil;
	[_accounts release], _accounts = nil;
	[_loginField release], _loginField = nil;
    [_passwordField release], _passwordField = nil;
    [_endpointField release], _endpointField = nil;
	[_saveButton release], _saveButton = nil;
    [super dealloc];
}

- (IBAction)saveAccount:(id)sender {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *login = [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
	NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
	NSString *endpoint = [self.endpointField.text stringByTrimmingCharactersInSet:trimSet];
	if ([login isEmpty] || [password isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a login and a password"];
	} else {
		[self.account setValue:login forKey:kLoginDefaultsKey];
		[self.account setValue:password forKey:kPasswordDefaultsKey];
		[self.account setValue:endpoint forKey:kEndpointDefaultsKey];
		// Add new account to list of accounts
		if (self.index == NSNotFound) [self.accounts addObject:self.account];
		// Save
		[AccountsController saveAccounts:self.accounts];
		// Go back
		[self.loginField resignFirstResponder];
		[self.passwordField resignFirstResponder];
		[self.endpointField resignFirstResponder];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.loginField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	[self.endpointField resignFirstResponder];
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.loginField) [self.passwordField becomeFirstResponder];
    if (textField == self.passwordField) [self.endpointField becomeFirstResponder];
    if (textField == self.endpointField) [self saveAccount:nil];
	return YES;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end