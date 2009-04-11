#import "WebViewController.h"


@implementation WebViewController

- (id)initWithURL:(NSURL *)theURL {
    if (self = [super initWithNibName:@"WebView" bundle:nil]) {
        url = [theURL retain];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [url absoluteString];
	// Add activity indicator to navbar
	UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingItem;
	[loadingItem release];
	// Start loading the website
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[webView loadRequest:request];
	[request release];
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

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[self webViewDidFinishLoad:webView];
	[webView stopLoading];
	webView.delegate = nil;
	[url release];
	[activityView release];
	[webView release];
    [super dealloc];
}


@end
