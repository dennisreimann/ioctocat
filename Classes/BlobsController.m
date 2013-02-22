#import "BlobsController.h"
#import "GHBlob.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface BlobsController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate> {
    CGRect _popupFrame;
}
@property(nonatomic,strong)GHBlob *blob;
@property(nonatomic,strong)NSArray *blobs;
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


@implementation BlobsController

- (id)initWithBlobs:(NSArray *)blobs currentIndex:(NSUInteger)idx {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.blobs = blobs;
		self.index = idx;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
    _popupFrame = self.popupView.frame;
	self.contentView.scrollView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
	self.blob = self.blobs[self.index];
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

- (void)displayCode:(NSString *)code {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	BOOL lineNumbers = [[defaults valueForKey:kLineNumbersDefaultsKey] boolValue];
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	if (!theme) theme = @"github";
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *codeCssPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"css"];
	NSString *lineNums = lineNumbers ? @"true" : @"false";
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *lang = @"";
	NSString *escapedCode = [code escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, lang, escapedCode];
	[self.contentView loadHTMLString:contentHTML baseURL:baseUrl];
}

- (void)displayData:(NSData *)data withFilename:(NSString *)filename {
	NSString *ext = [filename pathExtension];
	NSArray *imageTypes = @[@"jpg", @"jpeg", @"gif", @"png", @"tif", @"tiff"];
	NSString *mimeType;
	if ([imageTypes containsObject:ext]) {
		mimeType = [NSString stringWithFormat:@"image/%@", ext];
		[self.contentView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:nil];
		[self.contentView setScalesPageToFit:YES];
	} else {
		NSString *message = [NSString stringWithFormat:@"Cannot display %@", filename];
		[iOctocat reportError:@"Unknown content" with:message];
	}
}

- (void)displayBlob:(GHBlob *)blob {
	self.actionButton.enabled = YES;
	// check what type of content we have and display it accordingly
	if (self.blob.content) return [self displayCode:blob.content];
	if (self.blob.contentData) return [self displayData:blob.contentData withFilename:blob.path];
}

- (void)setBlob:(GHBlob *)blob {
	if (blob == self.blob) return;
    if (self.docInteractionController) [self.docInteractionController dismissMenuAnimated:YES];
	_blob = blob;
	[self.contentView stopLoading];
	self.title = self.blob.path;
	if (self.blob.isLoaded) {
		[self displayBlob:blob];
	} else {
        self.actionButton.enabled = NO;
		// when done, check if it's the current blob, because we might get notified
		// about a blob that has been loaded but is not the current one
		[self.blob loadWithParams:nil start:^(GHResource *instance) {
			[SVProgressHUD show];
		} success:^(GHResource *instance, id data) {
			if (blob == self.blob) {
                [self displayBlob:blob];
            }
		} failure:^(GHResource *instance, NSError *error) {
			if (blob == self.blob) {
				[iOctocat reportLoadingError:@"Could not load the file"];
			}
		}];
	}
	// Update navigation control
    self.leftButton.enabled = (self.index > 0);
    self.rightButton.enabled = (self.index < self.blobs.count-1);
}

- (IBAction)leftButtonTapped:(id)sender {
    self.index--;
    self.blob = self.blobs[self.index];
}

- (IBAction)rightButtonTapped:(id)sender {
    self.index++;
    self.blob = self.blobs[self.index];
}

- (IBAction)actionButtonTapped:(id)sender {
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.blob.path]];
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
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _popupFrame.origin.y = self.toolbar.frame.origin.y;
        self.popupView.frame = _popupFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.popupView removeFromSuperview];
        }
    }];
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
    NSData *data = nil;
    if (self.blob.content) {
        data = [self.blob.content dataUsingEncoding:NSUTF8StringEncoding];
    } else if (self.blob.contentData) {
        data = self.blob.contentData;
    }
    [data writeToURL:[controller URL] atomically:YES];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [[NSFileManager defaultManager] removeItemAtURL:[controller URL] error:nil];
}

@end