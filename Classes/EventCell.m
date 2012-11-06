#import "EventCell.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GravatarLoader.h"
#import "NSDate+Nibware.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"


@implementation EventCell

@synthesize event;
@synthesize delegate;

- (void)dealloc {
	[event.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[event release], event = nil;
	[dateLabel release], dateLabel = nil;
	[titleLabel release], titleLabel = nil;
	[actionsView release], actionsView = nil;
	[gravatarView release], gravatarView = nil;
	[iconView release], iconView = nil;
	[repositoryButton release], repositoryButton = nil;
	[otherRepositoryButton release], otherRepositoryButton = nil;
	[userButton release], userButton = nil;
	[otherUserButton release], otherUserButton = nil;
	[organizationButton release], organizationButton = nil;
	[issueButton release], issueButton = nil;
	[commitButton release], commitButton = nil;
	[gistButton release], gistButton = nil;
    [super dealloc];
}

- (void)setEvent:(GHEvent *)theEvent {
	[event.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[event release];
	event = [theEvent retain];
	titleLabel.text = event.title;
	// Date
    dateLabel.text = [event.date prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", event.extendedEventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	[event.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = event.user.gravatar;
	if (!gravatarView.image && !event.user.isLoaded) [event.user loadData];
	// actions
	NSMutableArray *buttons = [NSMutableArray array];
	if (event.user) [buttons addObject:userButton];
	if (event.organization) [buttons addObject:organizationButton];
	if (event.otherUser) [buttons addObject:otherUserButton];
	if (event.repository) [buttons addObject:repositoryButton];
	if (event.otherRepository) [buttons addObject:otherRepositoryButton];
	if (event.issue) [buttons addObject:issueButton];
	if (event.commits) [buttons addObject:commitButton];
	if (event.gist) [buttons addObject:gistButton];
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
	if ([keyPath isEqualToString:kGravatarKeyPath] && event.user.gravatar) {
		gravatarView.image = event.user.gravatar;
	}
}

#pragma mark Actions

- (IBAction)showRepository:(id)sender {
	if (delegate && event.repository) [delegate openEventItem:event.repository];
}

- (IBAction)showOtherRepository:(id)sender {
	if (delegate && event.otherRepository) [delegate openEventItem:event.otherRepository];
}

- (IBAction)showUser:(id)sender {
	if (delegate && event.repository) [delegate openEventItem:event.user];
}

- (IBAction)showOtherUser:(id)sender {
	if (delegate && event.otherUser) [delegate openEventItem:event.otherUser];
}

- (IBAction)showOrganization:(id)sender {
	if (delegate && event.organization) [delegate openEventItem:event.organization];
}

- (IBAction)showIssue:(id)sender {
	if (delegate && event.issue) [delegate openEventItem:event.issue];
}

- (IBAction)showCommit:(id)sender {
	GHCommit *commit = [event.commits objectAtIndex:0];
	if (delegate && commit) [delegate openEventItem:commit];
}

- (IBAction)showGist:(id)sender {
	if (delegate && event.gist) [delegate openEventItem:event.gist];
}

@end
