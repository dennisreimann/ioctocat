#import "DiffController.h"
#import "NSString+Extensions.h"


@interface DiffController ()
@property(nonatomic,retain)NSArray *files;
@property(nonatomic,assign)NSUInteger index;

- (NSString *)htmlFormatDiff:(NSString *)theDiff;
@end


@implementation DiffController

@synthesize files;
@synthesize index;

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
	return [[[self.class alloc] initWithFiles:theFiles currentIndex:theCurrentIndex] autorelease];
}

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
    [super initWithNibName:@"Diff" bundle:nil];
	self.files = theFiles;
	self.index = theCurrentIndex;
    return self;
}

- (void)dealloc {
    [contentView release], contentView = nil;
    [files release], files = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSDictionary *fileInfo = [files objectAtIndex:index];
	self.title = [[fileInfo objectForKey:@"filename"] lastPathComponent];
	NSString *patch = [fileInfo objectForKey:@"patch"];
	NSString *formattedPatch = [self htmlFormatDiff:patch];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *html = [NSString stringWithFormat:format, formattedPatch];
	[contentView loadHTMLString:html baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

- (NSString *)htmlFormatDiff:(NSString *)theDiff {
    NSString *escaped = [theDiff escapeHTML];
	NSArray *lines = [escaped componentsSeparatedByString:@"\n"];
	NSMutableString *patch = [NSMutableString string];
	for (NSString *line in lines) {
		if ([line hasPrefix:@"@@"]) {
			[patch appendFormat:@"<div class='lines'>%@</div>", line];
		} else if ([line hasPrefix:@"+"]) {
			[patch appendFormat:@"<div class='added'>%@</div>", line];
		} else if ([line hasPrefix:@"-"]) {
			[patch appendFormat:@"<div class='removed'>%@</div>", line];
		} else {
			[patch appendFormat:@"<div>%@</div>", line];
		}
	}
	return [NSString stringWithFormat:@"<pre id='diff' class='diff'>%@</pre>", patch];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSUInteger width = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('diff').scrollWidth"] intValue];
	if (width > webView.frame.size.width) {
		NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.width = '%dpx';", width];
		[webView stringByEvaluatingJavaScriptFromString:js];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
