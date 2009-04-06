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
	[super viewWillDisappear:animated];
	[webView stopLoading];
	webView.delegate = nil;
}

#pragma mark -
#pragma mark UIWebView delegation methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString *errorMessage = [error localizedDescription];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[url release];
	[activityView release];
	[webView release];
    [super dealloc];
}

@end
