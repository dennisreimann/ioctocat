#import "AccountController.h"
#import "MyFeedsController.h"
#import "GHUser.h"
#import "iOctocat.h"


@interface AccountController ()
- (void)authenticate;
@end


@implementation AccountController

@synthesize account;

- (id)initWithAccount:(GHAccount *)theAccount {
	[super initWithNibName:@"Account" bundle:nil];
	self.account = theAccount;
	return self;
}

- (void)dealloc {
	[feedController release], feedController = nil;
	[super dealloc];
}

- (UIView *)currentView {
    return self.modalViewController ? self.modalViewController.view : self.view;
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Authentication

- (LoginController *)loginController {
    if (!loginController) {
        loginController = [[LoginController alloc] initWithViewController:self];
        loginController.delegate = self;
    }
    return loginController;
}

- (void)authenticate {
	if (self.currentUser.isAuthenticated) return;
    [self.loginController setUser:self.currentUser];
	[self.loginController startAuthenticating];
}

- (void)finishedAuthenticating {
	if (self.currentUser.isAuthenticated) [feedController setupFeeds];
}

@end
