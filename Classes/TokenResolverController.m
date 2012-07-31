#import "TokenResolverController.h"


@interface TokenResolverController ()
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *password;
@end

@implementation TokenResolverController

@synthesize login;
@synthesize password;

- (id)initWithDelegate:(UIViewController *)theDelegate {
	[super init];
	delegate = theDelegate;
	return self;
}

- (void)dealloc {
	[login release], login = nil;
	[password release], password = nil;
    [super dealloc];
}

- (void)resolveForLogin:(NSString *)theLogin andPassword:(NSString *)thePassword {
	resolveSheet = [[UIActionSheet alloc] initWithTitle:@"\nResolving API token, please wait…\n\n"
											   delegate:self
									  cancelButtonTitle:nil
								 destructiveButtonTitle:nil
									  otherButtonTitles:nil];
	[resolveSheet showInView:[iOctocat sharedInstance].window];
	// start resolving
    NSURL *url = [NSURL URLWithString:@"https://github.com/login"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	UIWebView *webView = [[UIWebView alloc] init];
	webView.delegate = self;
	self.login = theLogin;
	self.password = thePassword;
	loginAttempts = 0;
    [webView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSString *path = [[webView.request URL] path];
    if ([path isEqualToString:@"/login"]) {
		NSString *js = [NSString stringWithFormat:@"$('#login_field').val('%@');$('#password').val('%@');$('#login_field')[0].form.submit()", login, password];
		loginAttempts += 1;
        [webView stringByEvaluatingJavaScriptFromString:js];
    } else if ([path isEqualToString:@"/"]) {
		if (loginAttempts == 0) {
			// If there is already a user signed in log out and re-login 
			[webView stringByEvaluatingJavaScriptFromString:@"if($('a#logout').length){$('a#logout').click()}else{window.location='https://github.com/login'}"];
		} else if (loginAttempts == 1) {
			NSString *token = [webView stringByEvaluatingJavaScriptFromString:@"$('a.feed')[0].href.match(/token=(.*)/)[1]"];
			if (![token isEqualToString:@""]) {
				[delegate performSelector:@selector(resolvedToken:forLogin:) withObject:token withObject:login];
				[webView release], webView = nil;
			}
			[self stopResolving];
		} else {
			[self stopResolving];
		}
    }
}

// TODO: We need to do this differently
- (void)stopResolving {
    [resolveSheet dismissWithClickedButtonIndex:0 animated:YES];
}

@end
