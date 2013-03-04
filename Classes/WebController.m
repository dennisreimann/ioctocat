#import "WebController.h"
#import "IOCApplication.h"


@interface WebController () <UIWebViewDelegate, UIActionSheetDelegate>
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *html;
@property(nonatomic,weak)IBOutlet UIWebView *webView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *leftButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *rightButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,weak)IBOutlet UIToolbar *toolbar;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;
- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
@end


@implementation WebController

- (id)initWithURL:(NSURL *)url {
	self = [super initWithNibName:@"WebView" bundle:nil];
	if (self) {
		self.url = url;
	}
	return self;
}

- (id)initWithHTML:(NSString *)html {
	self = [super initWithNibName:@"WebView" bundle:nil];
	if (self) {
		self.html = html;
	}
	return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self webViewDidFinishLoad:self.webView];
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];

	self.webView.scrollView.bounces = NO;
	if (self.url) {
		self.navigationItem.title = self.url.host;
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
		[self.webView loadRequest:request];
	} else if (self.html) {
		NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
		NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
		NSString *contentHTML = [NSString stringWithFormat:format, self.html];
		[self.webView loadHTMLString:contentHTML baseURL:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.webView stopLoading];
	self.webView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForInterfaceOrientation:interfaceOrientation];
}

#pragma mark Helpers

// Adjust the toolbar height depending on the screen orientation,
// see: http://stackoverflow.com/a/12111810/1104404
- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = CGRectMake(0.0f, self.view.bounds.size.height - toolbarSize.height, toolbarSize.width, toolbarSize.height);
    self.webView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.toolbar.frame.origin.y);
}

#pragma mark Actions

- (IBAction)leftButtonTapped:(id)sender {
    [self.webView goBack];
}

- (IBAction)rightButtonTapped:(id)sender {
    [self.webView goForward];
}

- (IBAction)actionButtonTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[self.webView.request URL] absoluteString] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy URL", nil];
    [actionSheet showFromToolbar:self.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [(IOCApplication *)[UIApplication sharedApplication] forceOpenURL:[self.webView.request URL]];
    else if (buttonIndex == 1) [UIPasteboard generalPasteboard].URL = [self.webView.request URL];
}

#pragma mark WebView

- (void)webViewDidStartLoad:(UIWebView *)webview {
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
    self.actionButton.enabled = [[self.webView.request URL] host] != nil;
	[self.activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
	self.navigationItem.title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
    self.actionButton.enabled = [[self.webView.request URL] host] != nil;
	[self.activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
    self.actionButton.enabled = [[self.webView.request URL] host] != nil;
	[self.activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end