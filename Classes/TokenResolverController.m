#import "TokenResolverController.h"


@interface TokenResolverController ()
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *password;

- (void)killTimeout;
@end

@implementation TokenResolverController

@synthesize login;
@synthesize password;

- (id)initWithDelegate:(UIViewController *)theDelegate {
	[super init];
	delegate = theDelegate;
	resolveSheet = [[UIActionSheet alloc] initWithTitle:@"\nResolving API token, please wait…\n\n"
											   delegate:self
									  cancelButtonTitle:nil
								 destructiveButtonTitle:nil
									  otherButtonTitles:nil];
	webView = [[UIWebView alloc] init];
	webView.delegate = self;
	return self;
}

- (void)dealloc {
	[self killTimeout];
	webView.delegate = nil;
	[webView release], webView = nil;
	[login release], login = nil;
	[password release], password = nil;
	[resolveSheet release], resolveSheet = nil;
    [super dealloc];
}

- (void)resolveForLogin:(NSString *)theLogin andPassword:(NSString *)thePassword {
	// prepare timeout
	[self killTimeout];
    timeout = [[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(fireTimeout) userInfo:nil repeats:NO] retain];
	
	[resolveSheet showInView:[iOctocat sharedInstance].window];
	// start resolving
    NSURL *url = [NSURL URLWithString:@"https://github.com/login"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	self.login = theLogin;
	self.password = thePassword;
	loginAttempts = 0;
    [webView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	NSString *path = [[theWebView.request URL] path];
	DJLog(@"Resolving token:  %@", path);
    if ([path isEqualToString:@"/login"]) {
		NSString *js = [NSString stringWithFormat:@"$('#login_field').val('%@');$('#password').val('%@');$('#login_field')[0].form.submit()", login, password];
		loginAttempts += 1;
        [theWebView stringByEvaluatingJavaScriptFromString:js];
    } else if ([path isEqualToString:@"/"]) {
		if (loginAttempts == 0) {
			// If there is already a user signed in log out and re-login 
			[theWebView stringByEvaluatingJavaScriptFromString:@"if($('a#logout').length){$('a#logout').click()}else{window.location='https://github.com/login'}"];
		} else if (loginAttempts == 1) {
			NSString *token = [theWebView stringByEvaluatingJavaScriptFromString:@"$('a.feed')[0].href.match(/token=(.*)/)[1]"];
			if (![token isEqualToString:@""]) {
				[delegate performSelector:@selector(resolvedToken:forLogin:) withObject:token withObject:login];
			} else {
				[delegate performSelector:@selector(resolvingTokenFailedForLogin:) withObject:login];
			}
			[self stopResolving];
		} else {
			[self stopResolving];
		}
    }
}

- (void)stopResolving {
	[self killTimeout];
    [resolveSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)fireTimeout {
	[self killTimeout];
	[self stopResolving];
	[iOctocat alert:@"Timeout" with:@"Resolving the token failed, we will try it again next time you log in :)"];
	[delegate performSelector:@selector(resolvingTokenFailedForLogin:) withObject:login];
}

- (void)killTimeout {
	if (timeout) {
        [timeout invalidate];
        [timeout release], timeout = nil;
    }
}

@end
