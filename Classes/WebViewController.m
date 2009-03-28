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
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingView;
	[loadingView release];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[webView loadRequest:request];
	[request release];
}

#pragma mark -
#pragma mark UIWebView delegation methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityView stopAnimating];
	NSString *errorMessage = [error localizedDescription];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	webView.delegate = nil;
	[url release];
	[activityView release];
	[webView release];
    [super dealloc];
}

@end
