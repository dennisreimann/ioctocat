#import "IOCWebController.h"
#import "IOCApplication.h"


@interface IOCWebController () <UIWebViewDelegate, UIActionSheetDelegate>
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *html;
@property(nonatomic,strong)NSURLRequest *request;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
@property(nonatomic,weak)IBOutlet UIWebView *webView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *leftButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *rightButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,weak)IBOutlet UIToolbar *toolbar;

- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
@end


@implementation IOCWebController

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
    _webView.delegate = nil;
    [_webView stopLoading];
    [self webView:_webView didFailLoadWithError:nil];
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
	self.webView.scrollView.bounces = NO;
	if (self.url) {
        self.title = self.title ? self.title : [self.url host];
        self.request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:self.request];
        self.actionButton.enabled = YES;
	} else if (self.html) {
        [self loadHtml];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
    if (!self.webView.delegate) self.webView.delegate = self;
    if (!self.webView.loading) {
        if (self.url) {
            [self.webView reload];
        } else if (self.html) {
            [self loadHtml];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self webView:self.webView didFailLoadWithError:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForInterfaceOrientation:interfaceOrientation];
}

#pragma mark Helpers

- (void)loadHtml {
    NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
    NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
    NSString *contentHTML = [NSString stringWithFormat:format, self.html];
    [self.webView loadHTMLString:contentHTML baseURL:nil];
}

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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.request.URL.absoluteString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy URL", nil];
    [actionSheet showFromToolbar:self.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [(IOCApplication *)[UIApplication sharedApplication] forceOpenURL:self.request.URL];
    else if (buttonIndex == 1) [UIPasteboard generalPasteboard].string = self.request.URL.absoluteString;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.webView.delegate = self;
    if (self.url) {
        [self.webView reload];
    } else if (self.html) {
        [self loadHtml];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self webView:self.webView didFailLoadWithError:nil];
}

#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        if (self.url) {
            self.title = url.host;
        } else if (self.html) {
            [[UIApplication sharedApplication] openURL:url];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview {
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
	[self.activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
    if (self.url) {
        self.title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.request = webview.request;
    }
	[self.activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
    self.leftButton.enabled = [webview canGoBack];
    self.rightButton.enabled = [webview canGoForward];
	[self.activityView stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end