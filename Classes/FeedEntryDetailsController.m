#import "FeedEntryDetailsController.h"
#import "UserViewController.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "Gravatar.h"


@implementation FeedEntryDetailsController

@synthesize entry;

- (id)initWithFeedEntry:(GHFeedEntry *)theEntry {
    if (self = [super initWithNibName:@"FeedEntryDetails" bundle:nil]) {
        self.entry = theEntry;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[entry.user addObserver:self forKeyPath:kUserGravatarImageKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [entry.eventType capitalizedString];
	titleLabel.text = entry.title;
	NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"styles" ofType:@"html"];
	NSString *style = [NSString stringWithContentsOfFile:stylePath encoding:NSUTF8StringEncoding error:nil];
	NSString *html = [NSString stringWithFormat:@"%@%@", style, entry.content];
	[contentView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://github.com/"]];
	// Date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:entry.date];
	[dateFormatter release];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	gravatarView.image = entry.user.gravatar.image;
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showUser:(id)sender {
	UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:entry.user];
	[self.navigationController pushViewController:userController animated:YES];
	[userController release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarImageKeyPath]) {
		gravatarView.image = entry.user.gravatar.image;
	}
}

#pragma mark -
#pragma mark UIWebView delegation methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	DebugLog(@"%@", request);
	return YES;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[contentView stopLoading];
	contentView.delegate = nil;
	[contentView release];
	[entry.user removeObserver:self forKeyPath:kUserGravatarImageKeyPath];
	[entry release];
	[dateLabel release];
	[titleLabel release];
	[iconView release];
	[gravatarView release];
    [super dealloc];
}

@end
