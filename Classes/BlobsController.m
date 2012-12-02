#import "BlobsController.h"
#import "GHBlob.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import <QuartzCore/QuartzCore.h>


@interface BlobsController ()
@property(nonatomic,strong)GHBlob *blob;
@property(nonatomic,strong)NSArray *blobs;
@property(nonatomic,assign)NSUInteger index;

- (void)displayBlob:(GHBlob *)theBlob;
- (void)displayCode:(NSString *)theCode withFilename:(NSString *)theFilename;
- (void)displayData:(NSData *)theData withFilename:(NSString *)theFilename;
@end


@implementation BlobsController

+ (id)controllerWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex {
	return [[self.class alloc] initWithBlobs:theBlobs currentIndex:theCurrentIndex];
}

- (id)initWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.blobs = theBlobs;
		self.index = theCurrentIndex;
	}
	return self;
}

- (void)dealloc {
	[self.blob removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.blobs.count > 1 ? self.controlItem : nil;
	self.blob = [self.blobs objectAtIndex:self.index];
	self.activityView.layer.cornerRadius = 10;
	self.activityView.layer.masksToBounds = YES;
	self.contentView.scrollView.bounces = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.contentView stopLoading];
	self.contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHBlob *theBlob = (GHBlob *)object;
		if (theBlob.isLoading) {
			[self.activityView setHidden:NO];
		} else {
			[self displayBlob:theBlob];
			if (!theBlob.error) return;
			[iOctocat reportLoadingError:@"Could not load the file"];
		}
	}
}

#pragma mark Actions

- (void)displayCode:(NSString *)theCode withFilename:(NSString *)theFilename {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	BOOL lineNumbers = [[defaults valueForKey:kLineNumbersDefaultsKey] boolValue];
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *codeCssPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"css"];
	NSString *lineNums = lineNumbers ? @"true" : @"false";
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [theCode escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, escapedCode];
	[self.contentView loadHTMLString:contentHTML baseURL:baseUrl];
}

- (void)displayData:(NSData *)theData withFilename:(NSString *)theFilename {
	NSString *ext = [theFilename pathExtension];
	NSArray *imageTypes = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"gif", @"png", @"tif", @"tiff", nil];
	NSString *mimeType;
	if ([imageTypes containsObject:ext]) {
		mimeType = [NSString stringWithFormat:@"image/%@", ext];
		[self.contentView loadData:theData MIMEType:mimeType textEncodingName:@"utf-8" baseURL:nil];
		[self.contentView setScalesPageToFit:YES];
	} else {
		[iOctocat reportError:@"Unknown content" with:[NSString stringWithFormat:@"Cannot display %@", theFilename]];
	}
}

- (void)displayBlob:(GHBlob *)theBlob {
	// check if it's the current blob, because we might get notified
	// about a blob that has been loaded but is not the current one
	if (theBlob != self.blob) return;
	[self.activityView setHidden:YES];
	// check what type of content we have and display it accordingly
	if (self.blob.content) return [self displayCode:theBlob.content withFilename:theBlob.path];
	if (self.blob.contentData) return [self displayData:theBlob.contentData withFilename:theBlob.path];
}

- (void)setBlob:(GHBlob *)theBlob {
	if (theBlob == self.blob) return;
	[theBlob addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.blob removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	_blob = theBlob;

	self.title = self.blob.path;
	self.blob.isLoaded ? [self displayBlob:theBlob] : [self.blob loadData];

	// Update navigation control
	[self.navigationControl setEnabled:(self.index > 0) forSegmentAtIndex:0];
	[self.navigationControl setEnabled:(self.index < self.blobs.count-1) forSegmentAtIndex:1];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	self.index += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.blob = [self.blobs objectAtIndex:self.index];
}

#pragma mark WebView

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.activityView setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.activityView setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self.activityView setHidden:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end