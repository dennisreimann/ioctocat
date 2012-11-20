#import "WebController.h"


@interface WebController ()
@property(nonatomic,retain)NSURL *url;
@property(nonatomic,retain)NSString *html;
@end


@implementation WebController

@synthesize url;
@synthesize html;

+ (id)controllerWithURL:(NSURL *)theURL {
	return [[[self.class alloc] initWithURL:theURL] autorelease];
}

+ (id)controllerWithHTML:(NSString *)theHTML {
	return [[[self.class alloc] initWithHTML:theHTML] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
	[super initWithNibName:@"WebView" bundle:nil];
	self.url = theURL;
	return self;
}

- (id)initWithHTML:(NSString *)theHTML {
	[super initWithNibName:@"WebView" bundle:nil];
	self.html = theHTML;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];

	webView.scrollView.bounces = NO;
	if (url) {
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
		[webView loadRequest:request];
		[request release];
	} else if (html) {
		NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
		NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
		NSString *contentHTML = [NSString stringWithFormat:format, html];
		[webView loadHTMLString:contentHTML baseURL:nil];
	}
}

- (void)dealloc {
	[self webViewDidFinishLoad:webView];
	[webView stopLoading];
	webView.delegate = nil;
	[url release], url = nil;
	[html release], html = nil;
	[activityView release], activityView = nil;
	[webView release], webView = nil;
	[super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[webView stopLoading];
	webView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark WebView

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

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end