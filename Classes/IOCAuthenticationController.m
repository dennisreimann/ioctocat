#import "IOCAuthenticationController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "SVProgressHUD.h"


@interface IOCAuthenticationController ()
@property(nonatomic,weak)UIViewController *delegate;
@property(nonatomic,strong)GHAccount *account;

- (void)setAccount:(GHAccount *)account;
@end


@implementation IOCAuthenticationController

- (id)initWithDelegate:(UIViewController *)delegate {
	self = [super init];
	self.delegate = delegate;
	return self;
}

- (void)dealloc {
	[self stopAuthenticating];
}

- (void)authenticateAccount:(GHAccount *)account {
	self.account = account;
	[self.account.user loadWithParams:nil start:^(GHResource *instance) {
		[SVProgressHUD showWithStatus:@"Authenticating…" maskType:SVProgressHUDMaskTypeGradient];
	} success:^(GHResource *instance, id data) {
		[self stopAuthenticating];
		[self.delegate performSelector:@selector(authenticatedAccount:) withObject:self.account];
	} failure:^(GHResource *instance, NSError *error) {
		[self stopAuthenticating];
		[self.delegate performSelector:@selector(authenticatedAccount:) withObject:self.account];
	}];
}

- (void)stopAuthenticating {
	[SVProgressHUD dismiss];
}

@end