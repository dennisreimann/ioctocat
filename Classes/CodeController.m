#import "CodeController.h"
#import "GHFiles.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "SVProgressHUD.h"


@interface CodeController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)NSDictionary *file;
@property(nonatomic,assign)NSUInteger index;
@property(nonatomic,strong)UIDocumentInteractionController *docInteractionController;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *leftButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *rightButton;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,weak)IBOutlet UIToolbar *toolbar;
- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
@end


@implementation CodeController

- (id)initWithFiles:(GHFiles *)files currentIndex:(NSUInteger)idx {
	self = [super initWithNibName:@"Code" bundle:nil];
	if (self) {
		self.files = files;
		self.index = idx;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.file = self.files[self.index];
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

- (void)setFile:(NSDictionary *)file {
	if (file == self.file) return;
	_file = file;
	[self.contentView stopLoading];
	NSString *fileName = [[self.file safeStringForKey:@"filename"] lastPathComponent];
	NSString *fileContent = [self.file safeStringForKey:@"content"];
	NSString *lang = [self.file safeStringForKey:@"language"];
	// if it's not a gist it must be a commit, so use the patch
	if (fileContent.isEmpty) {
		fileContent = [self.file safeStringForKey:@"patch"];
		lang = @"diff";
	}
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
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, lang, escapedCode];
	[self.contentView loadHTMLString:contentHTML baseURL:baseUrl];
	self.title = fileName;
	// Update navigation control
    self.leftButton.enabled = (self.index > 0);
    self.rightButton.enabled = (self.index < self.files.count - 1);
    self.actionButton.enabled = YES;
}

- (IBAction)leftButtonTapped:(id)sender {
    self.index--;
    self.file = self.files[self.index];
}

- (IBAction)rightButtonTapped:(id)sender {
    self.index++;
    self.file = self.files[self.index];
}

- (IBAction)actionButtonTapped:(id)sender {
    NSString *fileName = [[self.file safeStringForKey:@"filename"] lastPathComponent];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    if (!self.docInteractionController) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    } else {
        [self.docInteractionController setURL:url];
    }
    [self.docInteractionController presentOpenInMenuFromBarButtonItem:sender animated:YES];
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
    NSString *fileContent = [self.file safeStringForKey:@"content"];
    if (fileContent.isEmpty) {
        fileContent = [self.file safeStringForKey:@"patch"];
    }
    [[fileContent dataUsingEncoding:NSUTF8StringEncoding] writeToURL:[controller URL] atomically:YES];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [[NSFileManager defaultManager] removeItemAtURL:[controller URL] error:nil];
}

@end