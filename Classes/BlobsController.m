#import "BlobsController.h"
#import "GHBlob.h"
#import "NSString+Extensions.h"
#import <QuartzCore/QuartzCore.h>


@interface BlobsController ()
@property(nonatomic,retain)GHBlob *blob;
@property(nonatomic,retain)NSArray *blobs;
@property(nonatomic,assign)NSUInteger index;

- (void)displayBlob:(GHBlob *)theBlob;
- (void)displayCode:(NSString *)theCode withFilename:(NSString *)theFilename;
- (void)displayData:(NSData *)theData withFilename:(NSString *)theFilename;
@end


@implementation BlobsController

@synthesize blob;
@synthesize blobs;
@synthesize index;

+ (id)controllerWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex {
	return [[[self.class alloc] initWithBlobs:theBlobs currentIndex:theCurrentIndex] autorelease];
}

- (id)initWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex {
	[super initWithNibName:@"Code" bundle:nil];
	self.blobs = theBlobs;
	self.index = theCurrentIndex;
	return self;
}

- (void)dealloc {
	self.blob = nil;
	[navigationControl release], navigationControl = nil;
	[activityView release], activityView = nil;
	[controlItem release], controlItem = nil;
	[contentView release], contentView = nil;
	[blobs release], blobs = nil;
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = blobs.count > 1 ? controlItem : nil;
	self.blob = [blobs objectAtIndex:index];
	activityView.layer.cornerRadius = 10;
	activityView.layer.masksToBounds = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHBlob *theBlob = (GHBlob *)object;
		if (theBlob.isLoading) {
			[activityView setHidden:NO];
		} else {
			[self displayBlob:theBlob];
			if (!theBlob.error) return;
			[iOctocat alert:@"Loading error" with:@"Could not load the file"];
		}
	}
}

#pragma mark Actions

- (void)displayCode:(NSString *)theCode withFilename:(NSString *)theFilename {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	// get file extension to resolve the language and fallback to
	// the filename for files without extension (i.e. Rakefile)
	NSString *ext = [theFilename pathExtension];
	if (!ext) ext = theFilename;
	// resolve language
	NSString *languagesPath = [[NSBundle mainBundle] pathForResource:@"Languages" ofType:@"plist"];
	NSDictionary *languages = [NSDictionary dictionaryWithContentsOfFile:languagesPath];
	NSString *lang = [languages valueForKey:ext];
	if (!lang) lang = ext;
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [theCode escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, highlightJsPath, lang, escapedCode];
	[contentView loadHTMLString:contentHTML baseURL:baseUrl];
	DJLog(@"Highlighting %@", lang);
}

- (void)displayData:(NSData *)theData withFilename:(NSString *)theFilename {
	NSString *ext = [theFilename pathExtension];
	NSArray *imageTypes = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"gif", @"png", @"tif", @"tiff", nil];
	NSString *mimeType;
	if ([imageTypes containsObject:ext]) {
		mimeType = [NSString stringWithFormat:@"image/%@", ext];
		[contentView loadData:theData MIMEType:mimeType textEncodingName:@"utf-8" baseURL:nil];
		[contentView setScalesPageToFit:YES];
	} else {
		[iOctocat alert:@"Unknown content" with:[NSString stringWithFormat:@"Cannot display %@", theFilename]];
	}
}

- (void)displayBlob:(GHBlob *)theBlob {
	// check if it's the current blob, because we might get notified
	// about a blob that has been loaded but is not the current one
	if (theBlob != blob) return;
	[activityView setHidden:YES];
	// check what type of content we have and display it accordingly
	if (blob.content) return [self displayCode:theBlob.content withFilename:theBlob.path];
	if (blob.contentData) return [self displayData:theBlob.contentData withFilename:theBlob.path];
}

- (void)setBlob:(GHBlob *)theBlob {
	if (theBlob == blob) return;
	[theBlob retain];
	[theBlob addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[blob removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[blob release];
	blob = theBlob;
	
	self.title = blob.path;
	blob.isLoaded ? [self displayBlob:theBlob] : [blob loadData];
	
	// Update navigation control
	[navigationControl setEnabled:(index > 0) forSegmentAtIndex:0];
	[navigationControl setEnabled:(index < blobs.count-1) forSegmentAtIndex:1];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	index += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.blob = [blobs objectAtIndex:index];
}

#pragma mark WebView

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityView setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityView setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityView setHidden:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
