#import "FeedEntryController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "OrganizationController.h"
#import "GistController.h"
#import "WebController.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHOrganization.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHGist.h"
#import "GravatarLoader.h"
#import "CommitController.h"
#import "IssueController.h"
#import "IssuesController.h"
#import "iOctocat.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"


@interface FeedEntryController ()
@property(nonatomic,retain)GHFeed *feed;
@property(nonatomic,retain)GHFeedEntry *entry;
@end


@implementation FeedEntryController

@synthesize feed;
@synthesize entry;

- (id)initWithFeed:(GHFeed *)theFeed andCurrentIndex:(NSUInteger)theCurrentIndex {
	[super initWithNibName:@"FeedEntry" bundle:nil];
	currentIndex = theCurrentIndex;
	self.feed = theFeed;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (feed) {
		self.navigationItem.rightBarButtonItem = controlItem;
		self.entry = [feed.entries objectAtIndex:currentIndex];
	}
	
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground90.png"]];
    headView.backgroundColor = background;
}

- (void)setEntry:(GHFeedEntry *)theEntry {
	if (theEntry == entry) return;
	[theEntry retain];
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release];
	entry = theEntry;
	
	entry.read = YES;
	[entry.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [[entry.eventType capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
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
	if (!gravatarView.image && !entry.user.isLoaded) [entry.user loadData];
	// Update Toolbar
	NSMutableArray *tbItems = [NSMutableArray arrayWithObjects:webItem, (entry.eventType == @"team_add" ? organizationItem : firstUserItem), nil];
	if ([entry.eventItem isKindOfClass:[GHUser class]]) {
		[tbItems addObject:secondUserItem];
	} else if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
		[tbItems addObject:repositoryItem];
	} else if ([entry.eventItem isKindOfClass:[GHIssue class]]) {
		[tbItems addObject:repositoryItem];
		[tbItems addObject:issueItem];
	} else if ([entry.eventItem isKindOfClass:[GHCommit class]]) {
		[tbItems addObject:repositoryItem];
		[tbItems addObject:commitItem];
	} else if ([entry.eventItem isKindOfClass:[GHGist class]]) {
		[tbItems addObject:gistItem];
	}
	[toolbar setItems:tbItems animated:NO];
	// Update navigation control
	[navigationControl setEnabled:(currentIndex > 0) forSegmentAtIndex:0];
	[navigationControl setEnabled:(currentIndex < [feed.entries count]-1) forSegmentAtIndex:1];
}

- (void)dealloc {
	[contentView stopLoading];
	contentView.delegate = nil;
	[contentView release], contentView = nil;
	[toolbar release], toolbar = nil;
	[controlItem release], controlItem = nil;
	[webItem release], webItem = nil;
	[repositoryItem release], repositoryItem = nil;
	[firstUserItem release], firstUserItem = nil;
	[secondUserItem release], secondUserItem = nil;
	[issueItem release], issueItem = nil;
	[commitItem release], commitItem = nil;
	[gistItem release], gistItem = nil;
    [organizationItem release], organizationItem = nil;
	[navigationControl release], navigationControl = nil;
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release], entry = nil;
	[dateLabel release], dateLabel = nil;
	[titleLabel release], titleLabel = nil;
	[iconView release], iconView = nil;
	[headView release], headView = nil;
	[gravatarView release], gravatarView = nil;
	
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[contentView stopLoading];
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		gravatarView.image = entry.user.gravatar;
	}
}

#pragma mark Actions

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
	currentIndex += (segmentedControl.selectedSegmentIndex == 0) ? -1 : 1;
	self.entry = [feed.entries objectAtIndex:currentIndex];
}

- (IBAction)showInWebView:(id)sender {
	WebController *webController = [[WebController alloc] initWithURL:entry.linkURL];
	[self.navigationController pushViewController:webController animated:YES];
	[webController release];
}

- (IBAction)showRepository:(id)sender {
	id item = entry.eventItem;
	GHRepository *repository = nil;
    if ([item isKindOfClass:[GHRepository class]]) {
        repository = item;
    } else if ([item isKindOfClass:[GHIssue class]]) {
        repository = [(GHIssue *)item repository];
    } else if ([item isKindOfClass:[GHCommit class]]) {
        repository = [(GHCommit *)item repository];
    }
    if (repository) {
        RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repository];
        [self.navigationController pushViewController:repoController animated:YES];
        [repoController release];
    }
}

- (IBAction)showFirstUser:(id)sender {
	UserController *userController = [(UserController *)[UserController alloc] initWithUser:entry.user];
	[self.navigationController pushViewController:userController animated:YES];
	[userController release];
}

- (IBAction)showSecondUser:(id)sender {
	UserController *userController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)entry.eventItem];
	[self.navigationController pushViewController:userController animated:YES];
	[userController release];
}

- (IBAction)showOrganization:(id)sender {
	OrganizationController *orgController = [[OrganizationController alloc] initWithOrganization:(GHOrganization *)entry.organization];
	[self.navigationController pushViewController:orgController animated:YES];
	[orgController release];
}

- (IBAction)showIssue:(id)sender {
	GHIssue *issue = entry.eventItem;
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue andIssuesController:nil];
	[self.navigationController pushViewController:issueController animated:YES];
	[issueController release];
}

- (IBAction)showCommit:(id)sender {
	GHCommit *commit = entry.eventItem;
	CommitController *commitController = [[CommitController alloc] initWithCommit:commit];
	[self.navigationController pushViewController:commitController animated:YES];
	[commitController release];
}

- (IBAction)showGist:(id)sender {
	GHGist *gist = entry.eventItem;
	GistController *gistController = [GistController controllerWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[[request URL] absoluteString] isEqualToString:@"about:blank"]) return YES;
	NSArray *pathComponents = [[[[request URL] relativePath] substringFromIndex:1] componentsSeparatedByString:@"/"];
	NSString *host = [[request URL] host];
	DJLog(@"Host: %@, Path: %@, EventType: %@, EventItem: %@", host, pathComponents, entry.eventType, entry.eventItem);
	if ([pathComponents containsObject:@"commit"]) {
		NSString *sha = [pathComponents objectAtIndex:3];
		GHCommit *commit;
		if ([entry.eventItem isKindOfClass:[GHCommit class]]) {
			commit = entry.eventItem;
		} else if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
			commit = [[GHCommit alloc] initWithRepository:(GHRepository *)entry.eventItem andCommitID:sha];
		} else {
			NSString *owner = [pathComponents objectAtIndex:0];
			NSString *name = [pathComponents objectAtIndex:1];
			GHRepository *repo = [GHRepository repositoryWithOwner:owner andName:name];
			commit = [[GHCommit alloc] initWithRepository:repo andCommitID:sha];
		}
		CommitController *commitController = [[CommitController alloc] initWithCommit:commit];
		[self.navigationController pushViewController:commitController animated:YES];
		[commitController release];
		[commit release];
	} else if ([entry.eventItem isKindOfClass:[GHIssue class]] && [pathComponents containsObject:@"issues"]) {
		IssueController *issueController = [[IssueController alloc] initWithIssue:entry.eventItem andIssuesController:nil];
		[self.navigationController pushViewController:issueController animated:YES];
		[issueController release];
	} else if (pathComponents.count == 2) {
		NSString *owner = [pathComponents objectAtIndex:0];
		NSString *name = [pathComponents objectAtIndex:1];
		GHRepository *repo = [GHRepository repositoryWithOwner:owner andName:name];
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	} else if ([host isEqualToString:@"gist.github.com"] && pathComponents.count == 1) {
		NSString *gistId = [pathComponents objectAtIndex:0];
		GHGist *gist = [GHGist gistWithId:gistId];
		GistController *gistController = [GistController controllerWithGist:gist];
		[self.navigationController pushViewController:gistController animated:YES];
	} else if (pathComponents.count == 1) {
		NSString *username = [pathComponents objectAtIndex:0];
		GHUser *user = [[iOctocat sharedInstance] userWithLogin:username];
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else {
		WebController *webController = [[WebController alloc] initWithURL:[request URL]];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}
	return NO;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
