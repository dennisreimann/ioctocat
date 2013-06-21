#import "IOCCodeController.h"
#import "IOCUtil.h"
#import "GHFiles.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "SVProgressHUD.h"


@interface IOCCodeController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate> {
    CGRect _popupFrame;
}
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)NSDictionary *file;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,strong)UIDocumentInteractionController *docInteractionController;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *leftButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *rightButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,weak)IBOutlet UIToolbar *toolbar;
@property(nonatomic,strong)IBOutlet UIView *popupView;
- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
@end


@implementation IOCCodeController

- (id)initWithFiles:(GHFiles *)files currentIndex:(NSUInteger)idx {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.files = files;
		self.index = idx;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
    _popupFrame = self.popupView.frame;
	self.contentView.scrollView.bounces = NO;
    self.leftButton.accessibilityLabel = NSLocalizedString(@"Previous File", nil);
    self.rightButton.accessibilityLabel = NSLocalizedString(@"Next File", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
	self.file = self.files[self.index];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.contentView stopLoading];
	self.contentView.delegate = nil;
	[SVProgressHUD dismiss];
	[super viewWillDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForInterfaceOrientation:interfaceOrientation];
}

#pragma mark Helpers

- (void)setFile:(NSDictionary *)file {
	if (file == self.file) return;
    if (self.docInteractionController) [self.docInteractionController dismissMenuAnimated:YES];
    [self hidePopupView];
	_file = file;
	[self.contentView stopLoading];
	NSString *fileName = [[self.file ioc_stringForKey:@"filename"] lastPathComponent];
	NSString *fileContent = [self.file ioc_stringForKey:@"content"];
	NSString *lang = [[self.file ioc_stringForKey:@"language"] lowercaseString];
	// if it's not a gist it must be a commit, so use the patch
	if ([fileContent ioc_isEmpty]) {
		fileContent = [self.file ioc_stringForKey:@"patch"];
		lang = @"diff";
	}
    if ([lang ioc_isEmpty]) lang = [IOCUtil highlightLanguageForFilename:fileName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
	BOOL lineNumbers = [[defaults valueForKey:kLineNumbersDefaultsKey] boolValue];
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *codeCssPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"css"];
	NSString *lineNums = lineNumbers ? @"true" : @"false";
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [fileContent ioc_escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, lang, escapedCode];
	[self.contentView loadHTMLString:contentHTML baseURL:baseUrl];
	self.title = fileName;
	// Update navigation control
    self.leftButton.enabled = (self.index > 0);
    self.rightButton.enabled = (self.index < self.files.count - 1);
    self.actionButton.enabled = YES;
}

// Adjust the toolbar height depending on the screen orientation,
// see: http://stackoverflow.com/a/12111810/1104404
- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = CGRectMake(0.0f, self.view.bounds.size.height - toolbarSize.height, toolbarSize.width, toolbarSize.height);
    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.toolbar.frame.origin.y);
    if ([self.popupView isDescendantOfView:self.view]) {
        _popupFrame.origin.y = self.toolbar.frame.origin.y - _popupFrame.size.height;
        _popupFrame.size.width = self.view.bounds.size.width;
        self.popupView.frame = _popupFrame;
    }
}

- (void)hidePopupView {
    if ([self.popupView isDescendantOfView:self.view]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePopupView) object:nil];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            _popupFrame.origin.y = self.toolbar.frame.origin.y;
            self.popupView.frame = _popupFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.popupView removeFromSuperview];
            }
        }];
    }
}

#pragma mark Actions

- (IBAction)leftButtonTapped:(id)sender {
    self.index--;
    self.file = self.files[self.index];
}

- (IBAction)rightButtonTapped:(id)sender {
    self.index++;
    self.file = self.files[self.index];
}

- (IBAction)actionButtonTapped:(id)sender {
    NSString *fileName = [[self.file ioc_stringForKey:@"filename"] lastPathComponent];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    if (!self.docInteractionController) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    } else {
        [self.docInteractionController dismissMenuAnimated:NO];
        [self.docInteractionController setURL:url];
    }
    if (![self.docInteractionController presentOpenInMenuFromBarButtonItem:sender animated:YES]) {
        if (![self.popupView isDescendantOfView:self.view]) {
            _popupFrame.origin.y = self.toolbar.frame.origin.y;
            _popupFrame.size.width = self.view.bounds.size.width;
            self.popupView.frame = _popupFrame;
            [self.view insertSubview:self.popupView belowSubview:self.toolbar];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                _popupFrame.origin.y = self.toolbar.frame.origin.y - _popupFrame.size.height;
                self.popupView.frame = _popupFrame;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self performSelector:@selector(hidePopupView) withObject:nil afterDelay:5.0];
                }
            }];
        }
    }
}

#pragma mark WebView

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[SVProgressHUD dismiss];
}

#pragma mark DocumentInteractionController

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    NSString *fileContent = [self.file ioc_stringForKey:@"content"];
    if ([fileContent ioc_isEmpty]) {
        fileContent = [self.file ioc_stringForKey:@"patch"];
    }
    [[fileContent dataUsingEncoding:NSUTF8StringEncoding] writeToURL:[controller URL] atomically:YES];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [[NSFileManager defaultManager] removeItemAtURL:[controller URL] error:nil];
}

@end