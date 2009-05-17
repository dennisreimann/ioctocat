#import "WebController.h"


@implementation WebController

- (id)initWithURL:(NSURL *)theURL {
    [super initWithNibName:@"WebView" bundle:nil];
	url = [theURL retain];
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [url absoluteString];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
	// Start loading the website
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[webView loadRequest:request];
	[request release];
}

- (void)dealloc {
	[self webViewDidFinishLoad:webView];
	[webView stopLoading];
	webView.delegate = nil;
	[url release];
	[activityView release];
	[webView release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[webView stopLoading];
	webView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UIWebView delegation methods

- (void)webViewDidStartLoad:(UIWebView *)webview {
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
	[activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
	[activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
