#import "AuthenticationController.h"
#import "NSString+Extensions.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GradientButton.h"
#import "iOctocat.h"


@interface AuthenticationController ()
// TODO: Refactor this into its own class
- (void)resolveToken;
@end


@implementation AuthenticationController

- (id)initWithDelegate:(UIViewController *)theDelegate {
	[super init];
	delegate = theDelegate;
	return self;
}

- (void)dealloc {
    [self stopAuthenticating];
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
        if (account.user.isAuthenticated) {
			// TODO: Refactor
//			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//			NSString *token = [defaults stringForKey:kTokenDefaultsKey];
//			if ([token length] < 32) [self resolveToken];
			
			if ([delegate respondsToSelector:@selector(authenticatedAccount:)]) {
				[delegate performSelector:@selector(authenticatedAccount:) withObject:account];
			}
        } else {
			[iOctocat alert:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your login and password are correct"];
        }
    }
}

// TODO: We need to do this differently
- (void)stopAuthenticating {
	self.account = nil;
    [authSheet dismissWithClickedButtonIndex:0 animated:YES];
	[authSheet release], authSheet = nil;
}

#pragma mark Lookup API Token

- (void)resolveToken {
    UIWebView *webView = [[UIWebView alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://github.com/login"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    webView.delegate = self;
    [webView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([[[webView.request URL] path] isEqualToString:@"/login"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *login = [defaults stringForKey:kLoginDefaultsKey];
        NSString *password = [defaults stringForKey:kPasswordDefaultsKey];
        NSString *js = [NSString stringWithFormat:@"$('#login_field').val('%@');$('#password').val('%@');$('#login_field')[0].form.submit()", login, password];
        [webView stringByEvaluatingJavaScriptFromString:js];
    } else if ([[[webView.request URL] path] isEqualToString:@"/"]) {
        NSString *token = [webView stringByEvaluatingJavaScriptFromString:@"$('a.feed')[0].href.match(/token=(.*)/)[1]"];
        if (![token isEqualToString:@""]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:token forKey:kTokenDefaultsKey];
            [defaults synchronize];
            [webView release];
        }
    }
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
