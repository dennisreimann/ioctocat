#import "CodeController.h"
#import "NSString+Extensions.h"
#import <QuartzCore/QuartzCore.h>


@interface CodeController ()
@property(nonatomic,retain)NSDictionary *file;
@property(nonatomic,retain)NSArray *files;
@property(nonatomic,assign)NSUInteger index;
@end


@implementation CodeController

@synthesize file;
@synthesize files;
@synthesize index;

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
	return [[[self.class alloc] initWithFiles:theFiles currentIndex:theCurrentIndex] autorelease];
}

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
	[super initWithNibName:@"Code" bundle:nil];
	self.files = theFiles;
	self.index = theCurrentIndex;
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = files.count > 1 ? controlItem : nil;
	self.file = [files objectAtIndex:index];
	activityView.layer.cornerRadius = 10;
	activityView.layer.masksToBounds = YES;
}

- (void)dealloc {
	[contentView stopLoading];
	contentView.delegate = nil;
	[files release], files = nil;
	[contentView release], contentView = nil;
	[activityView release], activityView = nil;
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)setFile:(NSDictionary *)theFile {
	if (theFile == file) return;
	[theFile retain];
	[file release];
	file = theFile;
	
	NSString *fileName = [[file valueForKey:@"filename"] lastPathComponent];
	NSString *fileContent = [file valueForKey:@"content"];
	NSString *patch = [file valueForKey:@"patch"];
	
	// if it's not a gist it must be a commit, so use the patch 
	if (!fileContent) {
		fileContent = patch;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [fileContent escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, highlightJsPath, escapedCode];
	[contentView loadHTMLString:contentHTML baseURL:baseUrl];

	self.title = fileName;
	
	// Update navigation control
	[navigationControl setEnabled:(index > 0) forSegmentAtIndex:0];
	[navigationControl setEnabled:(index < files.count-1) forSegmentAtIndex:1];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	index += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.file = [files objectAtIndex:index];
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
