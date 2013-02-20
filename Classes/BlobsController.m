#import "BlobsController.h"
#import "GHBlob.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface BlobsController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>
@property(nonatomic,strong)GHBlob *blob;
@property(nonatomic,strong)NSArray *blobs;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *navigationControl;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *controlItem;
@property(nonatomic,weak)IBOutlet UIToolbar *toolbar;
@property(nonatomic,strong)UIDocumentInteractionController *docInteractionController;
@end


@implementation BlobsController

- (id)initWithBlobs:(NSArray *)blobs currentIndex:(NSUInteger)idx {
	self = [super initWithNibName:@"Blobs" bundle:nil];
	if (self) {
		self.blobs = blobs;
		self.index = idx;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	//self.navigationItem.rightBarButtonItem = self.blobs.count > 1 ? self.controlItem : nil;
    self.blob = self.blobs[self.index];
	self.contentView.scrollView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
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
        [self.navigationControl setEnabled:YES forSegmentAtIndex:0];
	} else {
        [self.navigationControl setEnabled:NO forSegmentAtIndex:0];
		[SVProgressHUD show];
		// when done, check if it's the current blob, because we might get notified
		// about a blob that has been loaded but is not the current one
		[self.blob loadWithParams:nil success:^(GHResource *instance, id data) {
			if (blob == self.blob) {
                [self displayBlob:blob];
                [self.navigationControl setEnabled:YES forSegmentAtIndex:0];
            }
		} failure:^(GHResource *instance, NSError *error) {
			if (blob == self.blob) {
                [iOctocat reportLoadingError:@"Could not load the file"];
                [self.navigationControl setEnabled:NO forSegmentAtIndex:0];
            }
		}];
	}
	// Update navigation control
	[self.navigationControl setEnabled:(self.index > 0) forSegmentAtIndex:1];
	[self.navigationControl setEnabled:(self.index < self.blobs.count-1) forSegmentAtIndex:2];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.blob.path]];
        if (!self.docInteractionController) {
            self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
            self.docInteractionController.delegate = self;
        } else {
            [self.docInteractionController setURL:url];
        }
        [self.docInteractionController presentOpenInMenuFromBarButtonItem:self.controlItem animated:YES];
    } else {
        self.index += (segmentedControl.selectedSegmentIndex == 1) ? -1 : 1;
        self.blob = self.blobs[self.index];
    }
}

// Adjust the toolbar height depending on the screen orientation,
// see: http://stackoverflow.com/a/12111810/1104404
- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = CGRectMake(0.0f, self.view.bounds.size.height - toolbarSize.height, toolbarSize.width, toolbarSize.height);
    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, CGRectGetMinY(self.toolbar.frame));
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