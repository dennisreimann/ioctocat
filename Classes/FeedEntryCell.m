#import "FeedEntryCell.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GravatarLoader.h"
#import "NSDate+Nibware.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"


@implementation FeedEntryCell

@synthesize entry;
@synthesize delegate;

- (void)dealloc {
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release], entry = nil;
	[dateLabel release], dateLabel = nil;
	[titleLabel release], titleLabel = nil;
	[actionsView release], actionsView = nil;
	[gravatarView release], gravatarView = nil;
	[iconView release], iconView = nil;
	[repositoryButton release], repositoryButton = nil;
	[firstUserButton release], firstUserButton = nil;
	[secondUserButton release], secondUserButton = nil;
	[organizationButton release], organizationButton = nil;
	[issueButton release], issueButton = nil;
	[commitButton release], commitButton = nil;
	[gistButton release], gistButton = nil;
    [super dealloc];
}

- (void)setEntry:(GHFeedEntry *)anEntry {
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release];
	entry = [anEntry retain];
	titleLabel.text = entry.title;
	// Date
    dateLabel.text = [entry.date prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	[entry.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = entry.user.gravatar;
	if (!gravatarView.image && !entry.user.isLoaded) [entry.user loadData];
	// Actionbar
	NSMutableArray *buttons = [NSMutableArray arrayWithObjects:(entry.eventType == @"team_add" ? organizationButton : firstUserButton), nil];
	if ([entry.eventItem isKindOfClass:[GHUser class]]) {
		[buttons addObject:secondUserButton];
	} else if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
		[buttons addObject:repositoryButton];
	} else if ([entry.eventItem isKindOfClass:[GHIssue class]]) {
		[buttons addObject:repositoryButton];
		[buttons addObject:issueButton];
	} else if ([entry.eventItem isKindOfClass:[GHCommit class]]) {
		[buttons addObject:repositoryButton];
		[buttons addObject:commitButton];
	} else if ([entry.eventItem isKindOfClass:[GHGist class]]) {
		[buttons addObject:gistButton];
	}
	// remove old action buttons
	for (UIView *subview in actionsView.subviews) {
		[subview removeFromSuperview];
	}
	// add new action buttons
	CGFloat w = 40.0;
	CGFloat h = 32.0;
	CGFloat m = 10.0;
	CGFloat o = self.frame.size.width;
	CGFloat x = o / 2 - (buttons.count * (w+m) / 2);
	CGFloat y = 6.0;
	for (UIButton *btn in buttons) {
		[actionsView addSubview:btn];
		btn.frame = CGRectMake(x, y, w, h);
		x += w + m;
	}
}

- (void)setCustomBackgroundColor:(UIColor *)theColor {
    if (!self.backgroundView) {
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    self.backgroundView.backgroundColor = theColor;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.45 saturation:0.05 brightness:0.9 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && entry.user.gravatar) {
		gravatarView.image = entry.user.gravatar;
	}
}

#pragma mark Actions

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
    if (repository && delegate) {
		[delegate openEventItem:repository];
	}
}

- (IBAction)showFirstUser:(id)sender {
	[delegate openEventItem:entry.user];
}

- (IBAction)showSecondUser:(id)sender {
	[delegate openEventItem:entry.eventItem];
}

- (IBAction)showOrganization:(id)sender {
	[delegate openEventItem:entry.organization];
}

- (IBAction)showIssue:(id)sender {
	[delegate openEventItem:entry.eventItem];
}

- (IBAction)showCommit:(id)sender {
	[delegate openEventItem:entry.eventItem];
}

- (IBAction)showGist:(id)sender {
	[delegate openEventItem:entry.eventItem];
}

@end
