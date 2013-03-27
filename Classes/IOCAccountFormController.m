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


@interface IOCAccountFormController () <UITextFieldDelegate, UIActionSheetDelegate>
@property(nonatomic,strong)GHAccount *account;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,readonly)NSString *deviceToken;
@property(nonatomic,weak)IBOutlet UITextField *loginField;
@property(nonatomic,weak)IBOutlet UITextField *passwordField;
@property(nonatomic,weak)IBOutlet UITextField *endpointField;
@property(nonatomic,weak)IBOutlet UISwitch *pushSwitch;
@property(nonatomic,weak)IBOutlet UILabel *pushLabel;
@property(nonatomic,weak)IBOutlet GradientButton *saveButton;
@property(nonatomic,weak)IBOutlet GradientButton *removeButton;
@end


@implementation IOCAccountFormController

static NSString *const AuthNote = @"iOctocat: Application";
static NSString *const PushNote = @"iOctocat: Push Notifications";

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
    self.loginField.keyboardType = UIKeyboardTypeEmailAddress;
	self.endpointField.text = self.account.endpoint;
    [self checkPushStateForPushToken:self.account.pushToken];
    [self.removeButton useRedDeleteStyle];
    self.removeButton.hidden = self.index == NSNotFound;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Helpers

- (NSString *)deviceToken {
    return [iOctocat sharedInstance].deviceToken;
}

- (NSString *)loginValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
    return value ? value : @"";
}

- (NSString *)passwordValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
    return value ? value : @"";
}

- (NSString *)endpointValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.endpointField.text stringByTrimmingCharactersInSet:trimSet];
    return value ? value : @"";
}

- (BOOL)hasDeviceToken {
    return self.deviceToken && !self.deviceToken.isEmpty;
}

- (BOOL)hasAuthToken {
    return self.account.authToken && !self.account.authToken.isEmpty;
}

- (BOOL)hasPushToken {
    return self.account.pushToken && !self.account.pushToken.isEmpty;
}

- (GHBasicClient *)apiClient {
	return [[GHBasicClient alloc] initWithEndpoint:self.endpointValue username:self.loginValue password:self.passwordValue];
}

- (void)saveAccount {
	[self.delegate updateAccount:self.account atIndex:self.index callback:^(NSUInteger idx) {
		self.index = idx;
        self.removeButton.hidden = self.index == NSNotFound;
	}];
}

- (void)checkPushStateForPushToken:(NSString *)pushToken {
	if (self.hasDeviceToken && !pushToken.isEmpty) {
		self.pushSwitch.enabled = NO;
		[IOCApiClient.sharedInstance checkPushNotificationsForDevice:self.deviceToken accessToken:pushToken success:^(id json) {
            self.account.pushToken = pushToken;
            [self saveAccount];
            [self.pushSwitch setOn:YES animated:YES];
            self.pushSwitch.enabled = YES;
            self.pushLabel.textColor = self.pushSwitch.enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
		} failure:^(NSError *error) {
            self.account.pushToken = @"";
            [self saveAccount];
            [self.pushSwitch setOn:NO animated:YES];
            self.pushSwitch.enabled = YES;
            self.pushLabel.textColor = self.pushSwitch.enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
		}];
	} else {
		self.pushSwitch.on = NO;
		self.pushSwitch.enabled = self.hasDeviceToken && self.hasAuthToken ? YES : NO;
        self.pushLabel.textColor = self.pushSwitch.enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
	}
}

#pragma mark Actions

- (IBAction)saveAccount:(id)sender {
	NSString *login = self.loginValue;
	NSString *endpoint = self.endpointValue;
	NSString *password = self.passwordValue;
    NSUInteger accountIdx = self.delegate ? [self.delegate indexOfAccountWithLogin:login endpoint:endpoint] : NSNotFound;
	if (login.isEmpty || password.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter your login and password"];
		return;
	} else if (accountIdx != self.index) {
        [iOctocat reportError:@"Duplicate account" with:@"This account already exists"];
		return;
    }
	NSArray	*scopes = @[@"user", @"repo", @"gist", @"notifications"];
	[SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeGradient];
	[self.apiClient saveAuthorizationWithNote:AuthNote scopes:scopes success:^(id json) {
		[SVProgressHUD showSuccessWithStatus:@"Authenticated"];
        [self.view endEditing:NO];
		// update
		self.account.login = login;
		self.account.endpoint = endpoint;
		self.account.authToken = [json safeStringForKey:@"token"];
		[self saveAccount];
        [self.apiClient findAuthorizationWithNote:PushNote success:^(id json) {
            NSString *pushToken = [json safeStringForKey:@"token"];
            [self checkPushStateForPushToken:pushToken];
        } failure:^(NSError *error) {
            [self checkPushStateForPushToken:@""];
        }];
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

- (IBAction)removeAccount:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove account" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        if (self.hasDeviceToken && self.hasPushToken) {
            [IOCApiClient.sharedInstance disablePushNotificationsForDevice:self.deviceToken accessToken:self.account.pushToken success:^(id json) {
                [self.delegate removeAccountAtIndex:self.index callback:^(NSUInteger idx) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } failure:^(NSError *error) {
                [iOctocat reportError:@"Removing account failed" with:@"Could not unregister push notifications, therefore cannot remove the account. Please try again later."];
			}];
        } else {
            [self.delegate removeAccountAtIndex:self.index callback:^(NSUInteger idx) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

// first request a separate oauth access token for the notifications scope from github,
// then call the ioctocat backend to submit the access token for this account.
- (void)enablePush {
    NSString *login = self.loginValue;
    NSString *endpoint = self.endpointValue;
	NSArray *scopes = @[@"notifications"];
	[SVProgressHUD showWithStatus:@"Enabling push notifications" maskType:SVProgressHUDMaskTypeGradient];
	[self.apiClient saveAuthorizationWithNote:PushNote scopes:scopes success:^(id json) {
		NSString *token = [json safeStringForKey:@"token"];
		[IOCApiClient.sharedInstance enablePushNotificationsForDevice:self.deviceToken accessToken:token endpoint:endpoint login:login success:^(id json) {
			[SVProgressHUD showSuccessWithStatus:@"Enabled push notifications"];
            self.account.login = login;
            self.account.endpoint = endpoint;
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
	[SVProgressHUD showWithStatus:@"Disabling push notifications" maskType:SVProgressHUDMaskTypeGradient];
	[IOCApiClient.sharedInstance disablePushNotificationsForDevice:self.deviceToken accessToken:self.account.pushToken success:^(id json) {
		[SVProgressHUD showSuccessWithStatus:@"Disabled push notifications"];
		self.account.pushToken = @"";
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

@end