#import "CodeController.h"
#import "NSString+Extensions.h"
#import <QuartzCore/QuartzCore.h>


@interface CodeController ()
@property(nonatomic,strong)NSDictionary *file;
@property(nonatomic,strong)NSArray *files;
@property(nonatomic,assign)NSUInteger index;
@end


@implementation CodeController

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
	return [[self.class alloc] initWithFiles:theFiles currentIndex:theCurrentIndex];
}

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.files = theFiles;
		self.index = theCurrentIndex;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.files.count > 1 ? self.controlItem : nil;
	self.file = [self.files objectAtIndex:self.index];
	self.activityView.layer.cornerRadius = 10;
	self.activityView.layer.masksToBounds = YES;
	self.contentView.scrollView.bounces = NO;
}

- (void)dealloc {
	[self.contentView stopLoading];
	self.contentView.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.contentView stopLoading];
	self.contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (void)setFile:(NSDictionary *)theFile {
	if (theFile == self.file) return;
	_file = theFile;

	NSString *fileName = [[self.file valueForKey:@"filename"] lastPathComponent];
	NSString *fileContent = [self.file valueForKey:@"content"];
	NSString *patch = [self.file valueForKey:@"patch"];

	// if it's not a gist it must be a commit, so use the patch
	if (!fileContent) fileContent = patch;

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
	NSString *escapedCode = [fileContent escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, escapedCode];
	[self.contentView loadHTMLString:contentHTML baseURL:baseUrl];

	self.title = fileName;

	// Update navigation control
	[self.navigationControl setEnabled:(self.index > 0) forSegmentAtIndex:0];
	[self.navigationControl setEnabled:(self.index < self.files.count - 1) forSegmentAtIndex:1];
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	self.index += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.file = [self.files objectAtIndex:self.index];
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