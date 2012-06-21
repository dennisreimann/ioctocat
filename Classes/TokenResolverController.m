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
    NSURL *url = [NSURL URLWithString:@"https://github.com/login"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	UIWebView *webView = [[UIWebView alloc] init];
	webView.delegate = self;
	self.login = theLogin;
	self.password = thePassword;
    [webView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSString *path = [[webView.request URL] path];
    if ([path isEqualToString:@"/login"]) {
        NSString *js = [NSString stringWithFormat:@"$('#login_field').val('%@');$('#password').val('%@');$('#login_field')[0].form.submit()", login, password];
        [webView stringByEvaluatingJavaScriptFromString:js];
    } else if ([path isEqualToString:@"/"]) {
        NSString *token = [webView stringByEvaluatingJavaScriptFromString:@"$('a.feed')[0].href.match(/token=(.*)/)[1]"];
        if (![token isEqualToString:@""]) {
            [delegate performSelector:@selector(resolvedToken:forLogin:) withObject:token withObject:login];
            [webView release], webView = nil;
        }
    }
}

@end
