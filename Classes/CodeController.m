#import "CodeController.h"
#import "NSString+Extensions.h"


@interface CodeController ()
@property(nonatomic,retain)NSString *code;
@property(nonatomic,retain)NSString *language;
@end


@implementation CodeController

@synthesize code;
@synthesize language;

+ (id)controllerWithCode:(NSString *)theCode language:(NSString *)theLang {
	return [[[self.class alloc] initWithCode:theCode language:theLang] autorelease];
}

- (id)initWithCode:(NSString *)theCode language:(NSString *)theLang {
	[super initWithNibName:@"WebView" bundle:nil];
	self.code = theCode;
	self.language = (theLang && ![theLang isKindOfClass:[NSNull class]] && ![theLang isEmpty]) ? [theLang lowercaseString] : @"generic";
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	NSString *lang = language;
	NSString *theme = [defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [code escapeHTML];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, highlightJsPath, lang, escapedCode];
	[webView loadHTMLString:contentHTML baseURL:baseUrl];
	DJLog(@"Highlighting %@", lang);
}

- (void)dealloc {
	[webView stopLoading];
	webView.delegate = nil;
	[code release], code = nil;
	[language release], language = nil;
	[webView release], webView = nil;
	[activityView release], activityView = nil;
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[webView stopLoading];
	webView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
