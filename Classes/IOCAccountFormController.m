#import "IOCAccountFormController.h"
#import "IOCAccountsController.h"
#import "IOCApiClient.h"
#import "GHBasicClient.h"
#import "GradientButton.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "SVProgressHUD.h"
#import "GHAccount.h"


@interface IOCAccountFormController () <UITextFieldDelegate>
@property(nonatomic,strong)GHAccount *account;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,weak)NSString *deviceToken;
@property(nonatomic,weak)IBOutlet UITextField *loginField;
@property(nonatomic,weak)IBOutlet UITextField *passwordField;
@property(nonatomic,weak)IBOutlet UITextField *endpointField;
@property(nonatomic,weak)IBOutlet UISwitch *pushSwitch;
@property(nonatomic,weak)IBOutlet UILabel *pushLabel;
@property(nonatomic,weak)IBOutlet GradientButton *saveButton;
@end


@implementation IOCAccountFormController

- (id)initWithAccount:(GHAccount *)account andIndex:(NSUInteger)idx {
    self = [super initWithNibName:@"AccountForm" bundle:nil];
	if (self) {
		self.index = idx;
		self.account = account;
		self.deviceToken = [iOctocat sharedInstance].deviceToken;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Account", self.index == NSNotFound ? @"New" : @"Edit"];
	self.loginField.text = self.account.login;
	self.endpointField.text = self.account.endpoint;
	self.pushSwitch.enabled = self.deviceToken ? YES : NO;
	self.pushLabel.textColor = self.deviceToken ? [UIColor blackColor] : [UIColor lightGrayColor];
	// check push state
	if (self.deviceToken && self.account.pushToken) {
		self.pushSwitch.enabled = NO;
		[[[IOCApiClient alloc] init] checkPushNotificationsForDevice:self.deviceToken accessToken:self.account.pushToken success:^(id json) {
			[self.pushSwitch setOn:YES animated:YES];
			self.pushSwitch.enabled = YES;
		} failure:^(NSError *error) {
			self.account.pushToken = nil;
			[self saveAccount];
			[self.pushSwitch setOn:NO animated:YES];
			self.pushSwitch.enabled = YES;
		}];
	} else {
		self.pushSwitch.on = NO;
		self.pushSwitch.enabled = self.deviceToken ? YES : NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Helpers

- (NSString *)loginValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	return [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
}

- (NSString *)passwordValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	return [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
}

- (NSString *)endpointValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	return [self.endpointField.text stringByTrimmingCharactersInSet:trimSet];
}

- (GHBasicClient *)apiClient {
	return [[GHBasicClient alloc] initWithEndpoint:self.endpointValue username:self.loginValue password:self.passwordValue];
}

- (void)saveAccount {
	[self.delegate updateAccount:self.account atIndex:self.index callback:^(NSUInteger idx) {
		self.index = idx;
	}];
}

#pragma mark Actions

- (IBAction)saveAccount:(id)sender {
	if (self.loginValue.isEmpty || self.passwordValue.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter your login and password"];
		return;
	}
	[self.view endEditing:NO];
	NSString *login = self.loginValue;
	NSString *endpoint = self.endpointValue;
	NSString *note = @"iOctocat: Application";
	NSArray	*scopes = @[@"user", @"repo", @"gist", @"notifications"];
	[SVProgressHUD showWithStatus:@"Authenticating…" maskType:SVProgressHUDMaskTypeGradient];
	[self.apiClient saveAuthorizationWithNote:note scopes:scopes success:^(id json) {
		[SVProgressHUD showSuccessWithStatus:@"Authenticated"];
		// update
		self.account.login = login;
		self.account.endpoint = endpoint;
		self.account.authToken = [json safeStringForKey:@"token"];
		[self saveAccount];
	} failure:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Authentication failed"];
	}];
}

- (IBAction)changePushNotifications:(id)sender {
	[self.view endEditing:NO];
	if (self.pushSwitch.on) {
		if (self.loginValue.isEmpty || self.passwordValue.isEmpty) {
			[iOctocat reportError:@"Credentials required" with:@"Please enter your login and password"];
			[self.pushSwitch setOn:NO animated:YES];
		} else {
			[self enablePush];
		}
	} else {
		[self disablePush];
	}
}

// first request a separate oauth access token for the notifications scope from github,
// then call the ioctocat backend to submit the access token for this account.
- (void)enablePush {
	NSString *note = @"iOctocat: Push Notifications";
	NSArray *scopes = @[@"notifications"];
	[SVProgressHUD showWithStatus:@"Enabling push notifications…" maskType:SVProgressHUDMaskTypeGradient];
	[self.apiClient saveAuthorizationWithNote:note scopes:scopes success:^(id json) {
		NSString *token = [json safeStringForKey:@"token"];
		[[[IOCApiClient alloc] init] enablePushNotificationsForDevice:self.deviceToken accessToken:token success:^(id json) {
			[SVProgressHUD showSuccessWithStatus:@"Enabled push notifications"];
			self.account.pushToken = token;
			[self saveAccount];
		} failure:^(NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Enabling push notifications failed"];
			[self.pushSwitch setOn:NO animated:YES];
		}];
	} failure:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Enabling push notifications failed"];
		[self.pushSwitch setOn:NO animated:YES];
	}];
}

// call the ioctocat backend to remove the access token for this account.
- (void)disablePush {
	NSString *token = self.account.pushToken;
	[SVProgressHUD showWithStatus:@"Disabling push notifications…" maskType:SVProgressHUDMaskTypeGradient];
	[[[IOCApiClient alloc] init] disablePushNotificationsForDevice:self.deviceToken accessToken:token success:^(id json) {
		[SVProgressHUD showSuccessWithStatus:@"Disabled push notifications"];
		self.account.pushToken = nil;
		[self saveAccount];
	} failure:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Disabling push notifications failed"];
		[self.pushSwitch setOn:YES animated:YES];
	}];
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