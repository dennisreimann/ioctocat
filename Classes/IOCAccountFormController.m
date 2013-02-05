#import "IOCAccountFormController.h"
#import "IOCAccountsController.h"
#import "GradientButton.h"
#import "iOctocat.h"
#import "GHApiClient.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "SVProgressHUD.h"
#import "GHAccount.h"


@interface IOCAccountFormController () <UITextFieldDelegate>
@property(nonatomic,strong)GHAccount *account;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,weak)IBOutlet UITextField *loginField;
@property(nonatomic,weak)IBOutlet UITextField *passwordField;
@property(nonatomic,weak)IBOutlet UITextField *endpointField;
@property(nonatomic,weak)IBOutlet UISwitch *pushSwitch;
@property(nonatomic,weak)IBOutlet GradientButton *saveButton;
@end


@implementation IOCAccountFormController

- (id)initWithAccount:(GHAccount *)account andIndex:(NSUInteger)idx {
    self = [super initWithNibName:@"AccountForm" bundle:nil];
	if (self) {
		self.index = idx;
		self.account = account;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Account", self.index == NSNotFound ? @"New" : @"Edit"];
	self.loginField.text = self.account.login;
	self.endpointField.text = self.account.endpoint;
	self.pushSwitch.on = self.account.pushEnabled;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Actions

- (IBAction)saveAccount:(id)sender {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *login = [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
	NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
	NSString *endpoint = [self.endpointField.text stringByTrimmingCharactersInSet:trimSet];
	if (login.isEmpty || password.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter your login and password"];
		return;
	}
	NSURL *apiURL = [NSURL URLWithString:kGitHubApiURL];
	NSString *oauthPath = [[NSBundle mainBundle] pathForResource:@"OAuth" ofType:@"plist"];
	NSDictionary *oauthParams = [NSDictionary dictionaryWithContentsOfFile:oauthPath];
	if (endpoint && !endpoint.isEmpty) {
		apiURL = [[NSURL smartURLFromString:endpoint] URLByAppendingPathComponent:kEnterpriseApiPath];
	}
	GHApiClient *apiClient = [[GHApiClient alloc] initWithBaseURL:apiURL];
	[apiClient setAuthorizationHeaderWithUsername:login password:password];
	// remove existing authId if the login changed,
	// because we are authenticating another user.
	NSString *oldLogin = self.account.login;
	if (![login isEqualToString:oldLogin]) {
		self.account.authId = nil;
	}
	// oauth request setup
	NSString *authId = self.account.authId;
	NSString *path = authId ? [NSString stringWithFormat:kAuthorizationFormat, authId] : kAuthorizationsFormat;
	NSString *method = authId ? kRequestMethodPatch : kRequestMethodPost;
	NSMutableURLRequest *request = [apiClient requestWithMethod:method path:path parameters:oauthParams];
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		D3JLog(@"OAuth request finished: %@", json);
		[SVProgressHUD showSuccessWithStatus:@"Authenticated"];
		NSString *authId = [json valueForKey:@"id"];
		NSString *token = [json valueForKey:@"token"];
		[self.account setValue:login forKey:kLoginDefaultsKey];
		[self.account setValue:token forKey:kAuthTokenDefaultsKey];
		[self.account setValue:authId forKey:kAuthIdDefaultsKey];
		[self.account setValue:endpoint forKey:kEndpointDefaultsKey];
		// save
		[self.delegate updateAccount:self.account atIndex:self.index];
		// go back
		[self.loginField resignFirstResponder];
		[self.passwordField resignFirstResponder];
		[self.endpointField resignFirstResponder];
		[self.navigationController popViewControllerAnimated:YES];
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		D3JLog(@"OAuth request failed: %@", error);
		[SVProgressHUD dismiss];
		[iOctocat reportError:@"Authentication failed" with:@"Please verify your login and password"];
		// remove existing authId if it could not be found.
		// this occurs when the user revoked the apps access.
		if (response.statusCode == 404) {
			self.account.authId = nil;
		}
	};
	D3JLog(@"OAuth request: %@ %@", method, path);
	[SVProgressHUD showWithStatus:@"Authenticating…" maskType:SVProgressHUDMaskTypeGradient];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
																						success:onSuccess
																						failure:onFailure];
	[operation start];
}

- (IBAction)changePushNotifications:(id)sender {
	if (self.pushSwitch.on) {
		NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSString *login = [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
		NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
		if (login.isEmpty || password.isEmpty) {
			[iOctocat reportError:@"Credentials required" with:@"Please enter your login and password"];
			[self.pushSwitch setOn:NO animated:YES];
		} else {
			[self enablePush];
		}
	} else {
		[self disablePush];
	}
}

- (void)enablePush {
	[self.account setValue:[NSNumber numberWithBool:YES] forKey:kPushNotificationsDefaultsKey];
	[self.delegate updateAccount:self.account atIndex:self.index];
}

- (void)disablePush {
	[self.account setValue:[NSNumber numberWithBool:NO] forKey:kPushNotificationsDefaultsKey];
	[self.delegate updateAccount:self.account atIndex:self.index];
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.loginField) [self.passwordField becomeFirstResponder];
    if (textField == self.passwordField) [self.endpointField becomeFirstResponder];
    if (textField == self.endpointField) [self saveAccount:nil];
	return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.view endEditing:NO];
}

@end