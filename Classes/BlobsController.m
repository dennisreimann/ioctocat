#import "BlobsController.h"
#import "GHBlob.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface BlobsController () <UIWebViewDelegate>
@property(nonatomic,strong)GHBlob *blob;
@property(nonatomic,strong)NSArray *blobs;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *navigationControl;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *controlItem;

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;
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

- (void)dealloc {
	[self.blob removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.blobs.count > 1 ? self.controlItem : nil;
	self.blob = self.blobs[self.index];
	self.contentView.scrollView.bounces = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.contentView stopLoading];
	self.contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHBlob *blob = (GHBlob *)object;
		if (blob.isLoading) {
			[SVProgressHUD show];
		} else {
			[self displayBlob:blob];
			if (!blob.error) return;
			[iOctocat reportLoadingError:@"Could not load the file"];
		}
	}
}

#pragma mark Actions

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
	// check if it's the current blob, because we might get notified
	// about a blob that has been loaded but is not the current one
	if (blob != self.blob) return;
	[SVProgressHUD dismiss];
	// check what type of content we have and display it accordingly
	if (self.blob.content) return [self displayCode:blob.content];
	if (self.blob.contentData) return [self displayData:blob.contentData withFilename:blob.path];
}

- (void)setBlob:(GHBlob *)blob {
	if (blob == self.blob) return;
	[blob addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.blob removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	_blob = blob;

	self.title = self.blob.path;
	self.blob.isLoaded ? [self displayBlob:blob] : [self.blob loadData];

	// Update navigation control
	[self.navigationControl setEnabled:(self.index > 0) forSegmentAtIndex:0];
	[self.navigationControl setEnabled:(self.index < self.blobs.count-1) forSegmentAtIndex:1];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	self.index += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.blob = self.blobs[self.index];
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

@end