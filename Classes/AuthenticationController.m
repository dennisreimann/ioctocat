#import "AuthenticationController.h"
#import "GHAccount.h"
#import "GHUser.h"


@interface AuthenticationController ()
- (void)setAccount:(GHAccount *)theAccount;
@end


@implementation AuthenticationController

- (id)initWithDelegate:(UIViewController *)theDelegate {
	[super init];
	delegate = theDelegate;
	return self;
}

- (void)dealloc {
    [self stopAuthenticating];
	self.account = nil;
	[authSheet release], authSheet = nil;
    [super dealloc];
}

- (void)setAccount:(GHAccount *)theAccount {
	[theAccount retain];
	// clear out old account
	[account removeObserver:self forKeyPath:@"user.loadingStatus"];
	[account release];
	// assign new account
	account = theAccount;
    [account addObserver:self forKeyPath:@"user.loadingStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)authenticateAccount:(GHAccount *)theAccount {
	self.account = theAccount;
	[account.user loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (account.user.isLoading) {
		authSheet = [[UIActionSheet alloc] initWithTitle:@"\nAuthenticating, please wait…\n\n"
												delegate:self
									   cancelButtonTitle:nil
								  destructiveButtonTitle:nil
									   otherButtonTitles:nil];
		[authSheet showInView:delegate.view];
	} else {
        [self stopAuthenticating];
		[delegate performSelector:@selector(authenticatedAccount:) withObject:account];
    }
}

// TODO: We need to do this differently
- (void)stopAuthenticating {
    [authSheet dismissWithClickedButtonIndex:0 animated:YES];
}

@end
