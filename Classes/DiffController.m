#import "DiffController.h"


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
	DJLog(@"Diff: %@", diff);
//	NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"styles" ofType:@"html"];
//	NSString *style = [NSString stringWithContentsOfFile:stylePath encoding:NSUTF8StringEncoding error:nil];
//	NSString *html = [NSString stringWithFormat:@"%@%@", style, diff];
//	[contentView loadHTMLString:html baseURL:nil];
	contentView.text = diff;
}

- (void)viewWillDisappear:(BOOL)animated {
//	[contentView stopLoading];
//	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}
					  
- (void)viewDidUnload {
	self.contentView = nil;
}

@end
