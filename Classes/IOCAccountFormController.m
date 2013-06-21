#import "IOCAccountFormController.h"
#import "IOCAccountsController.h"
#import "IOCApiClient.h"
#import "IOCTextField.h"
#import "GHBasicClient.h"
#import "GradientButton.h"
#import "iOctocat.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "SVProgressHUD.h"
#import "GHAccount.h"

typedef enum {
	IOCAccountTypeUnspecified = 0,
	IOCAccountTypeGitHubCom   = 1,
	IOCAccountTypeEnterprise  = 2
} IOCAccountType;


@interface IOCAccountFormController () <UITextFieldDelegate, UIActionSheetDelegate>
@property(nonatomic,strong)GHAccount *account;
@property(nonatomic,assign)IOCAccountType accountType;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,assign)BOOL wantsPushNeedsDeviceToken;
@property(nonatomic,readonly)NSString *deviceToken;
@property(nonatomic,weak)IBOutlet UIView *accountTypeView;
@property(nonatomic,weak)IBOutlet UIView *accountFormView;
@property(nonatomic,weak)IBOutlet IOCTextField *loginField;
@property(nonatomic,weak)IBOutlet IOCTextField *passwordField;
@property(nonatomic,weak)IBOutlet IOCTextField *endpointField;
@property(nonatomic,weak)IBOutlet UISwitch *pushSwitch;
@property(nonatomic,weak)IBOutlet UILabel *pushLabel;
@property(nonatomic,weak)IBOutlet GradientButton *onePasswordButton;
@property(nonatomic,weak)IBOutlet GradientButton *saveButton;
@property(nonatomic,weak)IBOutlet GradientButton *removeButton;
@end


@implementation IOCAccountFormController

static NSString *const AuthNote = @"iOctocat: Application";
static NSString *const PushNote = @"iOctocat: Push Notifications";
static NSString *const DeviceTokenKeyPath = @"deviceToken";

 - (id)initWithAccount:(GHAccount *)account andIndex:(NSUInteger)idx {
    self = [super initWithNibName:@"AccountForm" bundle:nil];
	if (self) {
		self.index = idx;
		self.account = account;
        if (self.isNewAccount) {
            self.accountType = IOCAccountTypeUnspecified;
        } else {
            self.accountType = self.account.isGitHub ? IOCAccountTypeGitHubCom : IOCAccountTypeEnterprise;
        }
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.loginField.text = self.account.login;
	self.endpointField.text = self.account.endpoint;
    [self checkPushStateForPushToken:self.account.pushToken];
    [self.removeButton useRedDeleteStyle];
    [self prepareForm];
    self.accountTypeView.hidden = self.accountType != IOCAccountTypeUnspecified;
    self.accountFormView.hidden = self.accountType == IOCAccountTypeUnspecified;
    self.onePasswordButton.hidden = ![UIApplication.sharedApplication canOpenURL:self.onePasswordURL];
    self.passwordField.textRectSubtractOnRight = self.onePasswordButton.hidden ? 0.0f : self.onePasswordButton.frame.size.width;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [iOctocat.sharedInstance addObserver:self forKeyPath:DeviceTokenKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [iOctocat.sharedInstance removeObserver:self forKeyPath:DeviceTokenKeyPath];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Helpers

- (BOOL)isNewAccount {
    return self.index == NSNotFound;
}

- (NSString *)deviceToken {
    return iOctocat.sharedInstance.deviceToken;
}

- (NSString *)loginValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.loginField.text stringByTrimmingCharactersInSet:trimSet];
    return value.length > 0 ? value : @"";
}

- (NSString *)passwordValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.passwordField.text stringByTrimmingCharactersInSet:trimSet];
    return value.length > 0 ? value : @"";
}

- (NSString *)endpointValue {
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *value = [self.endpointField.text stringByTrimmingCharactersInSet:trimSet];
    return value.length > 0 ? value : @"";
}

- (BOOL)hasDeviceToken {
    return self.deviceToken && ![self.deviceToken ioc_isEmpty];
}

- (BOOL)hasAuthToken {
    return self.account.authToken && ![self.account.authToken ioc_isEmpty];
}

- (BOOL)hasPushToken {
    return self.account.pushToken && ![self.account.pushToken ioc_isEmpty];
}

- (GHBasicClient *)apiClient {
	return [[GHBasicClient alloc] initWithEndpoint:self.endpointValue username:self.loginValue password:self.passwordValue];
}

- (void)saveAccount {
	[self.delegate updateAccount:self.account atIndex:self.index callback:^(NSUInteger idx) {
		self.index = idx;
        [self prepareForm];
	}];
}

- (void)checkPushStateForPushToken:(NSString *)pushToken {
	if (self.hasDeviceToken && ![pushToken ioc_isEmpty]) {
		[IOCApiClient.sharedInstance checkPushNotificationsForDevice:self.deviceToken accessToken:pushToken success:^(id json) {
            self.account.pushToken = pushToken;
            [self saveAccount];
            [self.pushSwitch setOn:YES animated:YES];
		} failure:^(NSError *error) {
            self.account.pushToken = @"";
            [self saveAccount];
            [self.pushSwitch setOn:NO animated:YES];
		}];
	} else {
		self.pushSwitch.on = NO;
	}
}

- (void)prepareForm {
    BOOL isEnterprise = self.accountType == IOCAccountTypeEnterprise;
    self.title = self.isNewAccount ? NSLocalizedString(@"New Account", @"Title: New Account") : NSLocalizedString(@"Edit Account", @"Title: Edit Account");
    // endpoint
    self.endpointField.text = isEnterprise ? self.account.endpoint : kGitHubComURL;
    self.endpointField.enabled = self.isNewAccount && isEnterprise;
    self.endpointField.textColor = self.endpointField.enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
    // push
    self.pushSwitch.enabled = self.hasAuthToken;
    self.pushLabel.textColor = self.pushSwitch.enabled ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
    // remove
    self.removeButton.hidden = self.isNewAccount;
}

- (NSURL *)onePasswordURL {
    NSString *query = [self.endpointValue ioc_isEmpty] ? @"" : [[NSURL ioc_smartURLFromString:self.endpointValue] host];
    return [NSURL ioc_URLWithFormat:@"onepassword://search/%@", query];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:DeviceTokenKeyPath] && self.deviceToken && self.wantsPushNeedsDeviceToken) {
        [self changePushNotifications:nil];
	}
}

#pragma mark Actions

- (IBAction)openOnePassword:(UIButton *)sender {
    [self.passwordField becomeFirstResponder];
    [[UIApplication sharedApplication] openURL:self.onePasswordURL];
}

- (IBAction)selectAccountType:(UIButton *)sender {
    self.accountType = sender.tag;
    [self prepareForm];
    UIViewAnimationOptions flip = self.accountType == IOCAccountTypeGitHubCom ?
        UIViewAnimationOptionTransitionFlipFromRight :
        UIViewAnimationOptionTransitionFlipFromLeft;
    UIViewAnimationOptions opts = (UIViewAnimationOptionShowHideTransitionViews | flip);
    [UIView transitionFromView:self.accountTypeView toView:self.accountFormView duration:0.4f options:opts completion:nil];
	
    if (self.accountType == IOCAccountTypeGitHubCom) {
        [self.loginField becomeFirstResponder];
    } else {
        [self.endpointField becomeFirstResponder];
    }
}

- (IBAction)saveAccount:(id)sender {
	NSString *login = self.loginValue;
	NSString *endpoint = self.endpointValue;
	NSString *password = self.passwordValue;
    NSUInteger accountIdx = self.delegate ? [self.delegate indexOfAccountWithLogin:login endpoint:endpoint] : NSNotFound;
	if ([endpoint ioc_isEmpty] || [login ioc_isEmpty] || [password ioc_isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter the domain, your login and password"];
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
		self.account.authToken = [json ioc_stringForKey:@"token"];
		[self saveAccount];
        [self.apiClient findAuthorizationWithNote:PushNote success:^(id json) {
            NSString *pushToken = [json ioc_stringForKey:@"token"];
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
    self.wantsPushNeedsDeviceToken = NULL;
    if (self.pushSwitch.on) {
        if (!self.hasDeviceToken) {
            // in case there is no device token yet, we have to ask the
            // users permissions to receive remote notifications first
            self.wantsPushNeedsDeviceToken = YES;
            [iOctocat.sharedInstance registerForRemoteNotifications];
        } else if ([self.loginValue ioc_isEmpty] || [self.passwordValue ioc_isEmpty]) {
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
		NSString *token = [json ioc_stringForKey:@"token"];
		[IOCApiClient.sharedInstance enablePushNotificationsForDevice:self.deviceToken accessToken:token endpoint:endpoint login:login success:^(id json) {
			[SVProgressHUD showSuccessWithStatus:@"Enabled push notifications"];
            self.account.login = login;
            self.account.endpoint = endpoint;
			self.account.pushToken = token;
			[self saveAccount];
		} failure:^(NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Enabling push notifications failed"];
            [iOctocat reportError:@"Remote server error" with:error.localizedDescription];
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
	if (textField == self.endpointField) [self.loginField becomeFirstResponder];
    if (textField == self.loginField) [self.passwordField becomeFirstResponder];
    if (textField == self.passwordField) [self saveAccount:nil];
	return YES;
}

@end
