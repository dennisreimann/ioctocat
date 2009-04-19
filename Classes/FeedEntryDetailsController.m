#import "FeedEntryDetailsController.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GHRepository.h"
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

- (IBAction)showActions:(id)sender {
	id eventItem = entry.eventItem;
	NSString *eventItemTitle = nil;
	if ([eventItem isKindOfClass:[GHRepository class]]) {
		eventItemTitle = [NSString stringWithFormat:@"Show %@", [(GHRepository *)eventItem name]];
	} else if ([eventItem isKindOfClass:[GHUser class]]) {
		eventItemTitle = [NSString stringWithFormat:@"Show %@", [(GHUser *)eventItem login]];
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View on GitHub", [NSString stringWithFormat:@"Show %@", entry.authorName], eventItemTitle, nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		WebViewController *webController = [[WebViewController alloc] initWithURL:entry.linkURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (buttonIndex == 1) {
		UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:entry.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (buttonIndex == 2) {
		if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
			RepositoryViewController *repoController = [[RepositoryViewController alloc] initWithRepository:(GHRepository *)entry.eventItem];
			[self.navigationController pushViewController:repoController animated:YES];
			[repoController release];
		} else if ([entry.eventItem isKindOfClass:[GHUser class]]) {
			UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:(GHUser *)entry.eventItem];
			[self.navigationController pushViewController:userController animated:YES];
			[userController release];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarImageKeyPath]) {
		gravatarView.image = entry.user.gravatar.image;
	}
}

#pragma mark -
#pragma mark UIWebView delegation methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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
