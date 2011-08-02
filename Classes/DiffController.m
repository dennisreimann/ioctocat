#import "DiffController.h"
#import "NSString+Extensions.h"


@interface DiffController ()
- (NSString *)htmlFormatDiff:(NSString *)theDiff;
@end


@implementation DiffController

@synthesize files;
@synthesize index;
@synthesize contentView;

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex {
    [super initWithNibName:@"Diff" bundle:nil];
	self.files = theFiles;
	self.index = theCurrentIndex;
    return self;
}

- (void)dealloc {
    [files release], files = nil;
    [contentView release], contentView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSDictionary *fileInfo = [files objectAtIndex:index];
	self.title = [[fileInfo objectForKey:@"filename"] lastPathComponent];
	NSString *diff = [fileInfo objectForKey:@"diff"];
	NSString *formattedDiff = [self htmlFormatDiff:diff];
	DJLog(@"Diff:\n-----------------------------------\n%@", diff);
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *html = [NSString stringWithFormat:format, formattedDiff];
	[contentView loadHTMLString:html baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}
					  
- (void)viewDidUnload {
	self.contentView = nil;
}

- (NSString *)htmlFormatDiff:(NSString *)theDiff {
    NSString *escaped = [theDiff escapeHTML];
	NSArray *lines = [escaped componentsSeparatedByString:@"\n"];
	NSMutableString *diff = [NSMutableString string];
	for (NSString *line in lines) {
		if ([line hasPrefix:@"@@"]) {
			[diff appendFormat:@"<div class='lines'>%@</div>", line];
		} else if ([line hasPrefix:@"+"]) {
			[diff appendFormat:@"<div class='added'>%@</div>", line];
		} else if ([line hasPrefix:@"-"]) {
			[diff appendFormat:@"<div class='removed'>%@</div>", line];
		} else {
			[diff appendFormat:@"<div>%@</div>", line];
		}
	}
	return [NSString stringWithFormat:@"<pre id='diff' class='diff'>%@</pre>", diff];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSUInteger width = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('diff').scrollWidth"] intValue];
	if (width > webView.frame.size.width) {
		NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.width = '%dpx';", width];
		[webView stringByEvaluatingJavaScriptFromString:js];
		DJLog(@"Reset width: %@", js);
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
