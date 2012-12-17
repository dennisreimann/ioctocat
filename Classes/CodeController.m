#import "CodeController.h"
#import "NSString+Extensions.h"


@interface CodeController () <UIWebViewDelegate>
@property(nonatomic,strong)NSDictionary *file;
@property(nonatomic,strong)NSArray *files;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,weak)IBOutlet UIView *activityView;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *navigationControl;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *controlItem;

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;
@end


@implementation CodeController

- (id)initWithFiles:(NSArray *)files currentIndex:(NSUInteger)idx {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.files = files;
		self.index = idx;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.files.count > 1 ? self.controlItem : nil;
	self.file = (self.files)[self.index];
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

- (void)setFile:(NSDictionary *)file {
	if (file == self.file) return;
	_file = file;

	NSString *fileName = [[self.file valueForKey:@"filename"] lastPathComponent];
	NSString *fileContent = [self.file valueForKey:@"content"];
	NSString *patch = [self.file valueForKey:@"patch"];

	// if it's not a gist it must be a commit, so use the patch
	if (!fileContent) fileContent = patch;

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
	self.file = (self.files)[self.index];
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