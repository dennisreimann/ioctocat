#import "WebController.h"


@interface WebController ()
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *html;
@end


@implementation WebController

- (id)initWithURL:(NSURL *)theURL {
	self = [super initWithNibName:@"WebView" bundle:nil];
	if (self) {
		self.url = theURL;
	}
	return self;
}

- (id)initWithHTML:(NSString *)theHTML {
	self = [super initWithNibName:@"WebView" bundle:nil];
	if (self) {
		self.html = theHTML;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];

	self.webView.scrollView.bounces = NO;
	if (self.url) {
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
		[self.webView loadRequest:request];
	} else if (self.html) {
		NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
		NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
		NSString *contentHTML = [NSString stringWithFormat:format, self.html];
		[self.webView loadHTMLString:contentHTML baseURL:nil];
	}
}

- (void)dealloc {
	[self webViewDidFinishLoad:self.webView];
	[self.webView stopLoading];
	self.webView.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.webView stopLoading];
	self.webView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark WebView

- (void)webViewDidStartLoad:(UIWebView *)webview {
	[self.activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
	[self.activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
	[self.activityView stopAnimating];
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