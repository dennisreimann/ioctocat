#import "EventCell.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GravatarLoader.h"
#import "NSDate+Nibware.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHPullRequest.h"


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
	dateLabel.text = [event.date prettyDate];
	[self setContentText:event.content];
	NSString *icon = [NSString stringWithFormat:@"%@.png", event.extendedEventType];
	iconView.image = [UIImage imageNamed:icon];
	[event.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = event.user.gravatar;
	if (!gravatarView.image && !event.user.gravatarURL) [event.user loadData];
	// actions
	NSMutableArray *buttons = [NSMutableArray array];
	if (event.user) [buttons addObject:userButton];
	if (event.organization) [buttons addObject:organizationButton];
	if (event.otherUser) [buttons addObject:otherUserButton];
	if (event.repository) [buttons addObject:repositoryButton];
	if (event.otherRepository) [buttons addObject:otherRepositoryButton];
	if (event.issue && !event.pullRequest) [buttons addObject:issueButton];
	if (event.commits) [buttons addObject:commitButton];
	if (event.gist) [buttons addObject:gistButton];
	// remove old action buttons
	for (UIView *subview in actionsView.subviews) {
		[subview removeFromSuperview];
	}
	// add new action buttons
	CGFloat w = 48.0;
	CGFloat h = 36.0;
	CGFloat m = 12.0;
	CGFloat o = self.frame.size.width;
	CGFloat x = o / 2 - (buttons.count * (w+m) / 2);
	CGFloat y = 9.0;
	for (UIButton *btn in buttons) {
		[actionsView addSubview:btn];
		btn.frame = CGRectMake(x, y, w, h);
		x += w + m;
	}
	// position action view at bottom
	CGRect frame = actionsView.frame;
	frame.origin.y = contentTextView.frame.origin.y + contentTextView.frame.size.height;
	actionsView.frame = frame;
}

- (void)setCustomBackgroundColor:(UIColor *)theColor {
	if (!self.backgroundView) {
			self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	}
	self.backgroundView.backgroundColor = theColor;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.586 saturation:0.087 brightness:1.0 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
	event.read = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    for (UIButton *btn in actionsView.subviews) [btn setHighlighted:NO];
	[self markAsRead];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    for (UIButton *btn in actionsView.subviews) [btn setHighlighted:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && event.user.gravatar) {
		gravatarView.image = event.user.gravatar;
	}
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	return 70.0f + [super heightForTableView:tableView] + actionsView.frame.size.height;
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

#pragma mark Layout

- (CGFloat)marginTop {
	return 0.0f;
}

- (CGFloat)marginRight {
	return 1.0f;
}

- (CGFloat)marginBottom {
	return 0.0f;
}

- (CGFloat)marginLeft {
	return 1.0f;
}

@end