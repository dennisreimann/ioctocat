#import "FeedEntryController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GravatarLoader.h"
#import "CommitController.h"
#import "iOctocat.h"
#import "NSDate+Nibware.h"


@interface FeedEntryController ()
- (void)displayEntry;
@end


@implementation FeedEntryController

@synthesize feed;
@synthesize entry;

- (id)initWithFeed:(GHFeed *)theFeed andCurrentIndex:(NSUInteger)theCurrentIndex {
	[super initWithNibName:@"FeedEntry" bundle:nil];
	currentIndex = theCurrentIndex;
	self.feed = theFeed;
	self.entry = [feed.entries objectAtIndex:currentIndex];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (feed) self.navigationItem.rightBarButtonItem = controlItem;
	[self displayEntry];
}

- (void)displayEntry {
	entry.read = YES;
	[entry.user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [entry.eventType capitalizedString];
	titleLabel.text = entry.title;
	NSString *feedEntry = [NSString stringWithFormat:@"<div class='feed_entry'>%@</div>", entry.content];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *html = [NSString stringWithFormat:format, feedEntry];
	[contentView loadHTMLString:html baseURL:nil];
	// Date
	dateLabel.text = [entry.date prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	gravatarView.image = entry.user.gravatar;
	// Update navigation control
	[navigationControl setEnabled:(currentIndex > 0) forSegmentAtIndex:0];
	[navigationControl setEnabled:(currentIndex < [feed.entries count]-1) forSegmentAtIndex:1];
}

- (void)dealloc {
	[contentView stopLoading];
	contentView.delegate = nil;
	[contentView release];
	[controlItem release];
	[webItem release];
	[repositoryItem release];
	[firstUserItem release];
	[secondUserItem release];
	[watchItem release];
	[unwatchItem release];
	[issueItem release];
	[navigationControl release];
	[entry.user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[entry release];
	[dateLabel release];
	[titleLabel release];
	[iconView release];
	[gravatarView release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	contentView.delegate = nil;
	[super viewWillDisappear:animated];
}

#pragma mark Actions

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	currentIndex += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	[entry.user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	self.entry = [feed.entries objectAtIndex:currentIndex];
	[self displayEntry];
}

- (IBAction)showActions:(id)sender {
	id eventItem = entry.eventItem;
	NSString *eventItemTitle = nil;
	if ([eventItem isKindOfClass:[GHCommit class]]) {
		eventItemTitle = [NSString stringWithFormat:@"Show %@", [[(GHCommit *)eventItem repository] name]];
	} else if ([eventItem isKindOfClass:[GHRepository class]]) {
		eventItemTitle = [NSString stringWithFormat:@"Show %@", [(GHRepository *)eventItem name]];
	} else if ([eventItem isKindOfClass:[GHUser class]]) {
		eventItemTitle = [NSString stringWithFormat:@"Show %@", [(GHUser *)eventItem login]];
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View on GitHub", [NSString stringWithFormat:@"Show %@", entry.authorName], eventItemTitle, nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		WebController *webController = [[WebController alloc] initWithURL:entry.linkURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (buttonIndex == 1) {
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:entry.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (buttonIndex == 2 ) {
		if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
			RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:(GHRepository *)entry.eventItem];
			[self.navigationController pushViewController:repoController animated:YES];
			[repoController release];
		} else if ([entry.eventItem isKindOfClass:[GHUser class]]) {
            UserController *userController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)entry.eventItem];
			[self.navigationController pushViewController:userController animated:YES];
			[userController release];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
		gravatarView.image = entry.user.gravatar;
	}
}

#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[[request URL] absoluteString] isEqualToString:@"about:blank"]) return YES;
	NSArray *pathComponents = [[[[request URL] relativePath] substringFromIndex:1] componentsSeparatedByString:@"/"];
	DJLog(@"Path: %@", pathComponents);
	if ([pathComponents containsObject:@"commit"]) {
		NSString *sha = [pathComponents lastObject];
		GHCommit *commit = [[GHCommit alloc] initWithRepository:(GHRepository *)entry.eventItem andCommitID:sha];
		CommitController *commitController = [[CommitController alloc] initWithCommit:commit];
		[self.navigationController pushViewController:commitController animated:YES];
		[commitController release];
	} else if ([entry.eventItem isKindOfClass:[GHRepository class]] && [entry.content rangeOfString:@" is at"].location != NSNotFound) {
		NSString *owner = [pathComponents objectAtIndex:[pathComponents count]-2];
		NSString *name = [pathComponents objectAtIndex:[pathComponents count]-1];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
		[repo release];
	} else if ([pathComponents count] == 1) {
		NSString *username = [pathComponents objectAtIndex:0];
		GHUser *user = [[iOctocat sharedInstance] userWithLogin:username];
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
		[user release];
	}
	return NO;
}

@end
