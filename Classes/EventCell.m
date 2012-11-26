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


@interface EventCell ()
- (void)positionActionView;
@end


@implementation EventCell

- (void)dealloc {
	[self.event.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_event release], _event = nil;
	[_dateLabel release], _dateLabel = nil;
	[_titleLabel release], _titleLabel = nil;
	[_actionsView release], _actionsView = nil;
	[_gravatarView release], _gravatarView = nil;
	[_iconView release], _iconView = nil;
	[_repositoryButton release], _repositoryButton = nil;
	[_otherRepositoryButton release], _otherRepositoryButton = nil;
	[_userButton release], _userButton = nil;
	[_otherUserButton release], _otherUserButton = nil;
	[_organizationButton release], _organizationButton = nil;
	[_issueButton release], _issueButton = nil;
	[_pullRequestButton release], _pullRequestButton = nil;
	[_wikiButton release], _wikiButton = nil;
	[_commitButton release], _commitButton = nil;
	[_gistButton release], _gistButton = nil;
	[super dealloc];
}

- (void)setEvent:(GHEvent *)theEvent {
	[theEvent retain];
	[self.event.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_event release];
	_event = theEvent;
	self.titleLabel.text = self.event.title;
	self.dateLabel.text = [self.event.date prettyDate];
	[self setContentText:self.event.content];
	NSString *icon = [NSString stringWithFormat:@"%@.png", self.event.extendedEventType];
	self.iconView.image = [UIImage imageNamed:icon];
	[self.event.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.gravatarView.image = self.event.user.gravatar;
	if (!self.gravatarView.image && !self.event.user.gravatarURL) [self.event.user loadData];
	// actions
	NSMutableArray *buttons = [NSMutableArray array];
	if (self.event.user) [buttons addObject:self.userButton];
	if (self.event.organization) [buttons addObject:self.organizationButton];
	if (self.event.otherUser) [buttons addObject:self.otherUserButton];
	if (self.event.repository) [buttons addObject:self.repositoryButton];
	if (self.event.otherRepository) [buttons addObject:self.otherRepositoryButton];
	if (self.event.issue && !self.event.pullRequest) [buttons addObject:self.issueButton];
	if (self.event.pullRequest) [buttons addObject:self.pullRequestButton];
	if (self.event.commits) [buttons addObject:self.commitButton];
	if (self.event.gist) [buttons addObject:self.gistButton];
	if (self.event.pages) [buttons addObject:self.wikiButton];
	// remove old action buttons
	for (UIView *subview in self.actionsView.subviews) {
		[subview removeFromSuperview];
	}
	// add new action buttons
	CGFloat w = 46.0f;
	CGFloat h = 36.0f;
	CGFloat m = 12.0f;
	CGFloat x = 0.0f;
	CGFloat y = 3.0f;
	for (UIButton *btn in buttons) {
		[self.actionsView addSubview:btn];
		btn.frame = CGRectMake(x, y, w, h);
		x += w + m;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self positionActionView];
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
	self.event.read = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    for (UIButton *btn in self.actionsView.subviews) [btn setHighlighted:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    for (UIButton *btn in self.actionsView.subviews) [btn setHighlighted:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && self.event.user.gravatar) {
		self.gravatarView.image = self.event.user.gravatar;
	}
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	return self.normalHeight + [super heightForTableView:tableView] + self.actionsView.frame.size.height;
}

#pragma mark Actions

- (IBAction)showRepository:(id)sender {
	if (self.delegate && self.event.repository) [self.delegate openEventItem:self.event.repository];
}

- (IBAction)showOtherRepository:(id)sender {
	if (self.delegate && self.event.otherRepository) [self.delegate openEventItem:self.event.otherRepository];
}

- (IBAction)showUser:(id)sender {
	if (self.delegate && self.event.repository) [self.delegate openEventItem:self.event.user];
}

- (IBAction)showOtherUser:(id)sender {
	if (self.delegate && self.event.otherUser) [self.delegate openEventItem:self.event.otherUser];
}

- (IBAction)showOrganization:(id)sender {
	if (self.delegate && self.event.organization) [self.delegate openEventItem:self.event.organization];
}

- (IBAction)showIssue:(id)sender {
	if (self.delegate && self.event.issue) [self.delegate openEventItem:self.event.issue];
}

- (IBAction)showPullRequest:(id)sender {
	if (self.delegate && self.event.pullRequest) [self.delegate openEventItem:self.event.pullRequest];
}

- (IBAction)showWiki:(id)sender {
	NSDictionary *wiki = [self.event.pages objectAtIndex:0];
	if (self.delegate && wiki) [self.delegate openEventItem:wiki];
}

- (IBAction)showCommit:(id)sender {
	if (self.event.commits.count == 1) {
		GHCommit *commit = [self.event.commits objectAtIndex:0];
		if (self.delegate) [self.delegate openEventItem:commit];
	} else if (self.event.commits.count > 1) {
		if (self.delegate) [self.delegate openEventItem:self.event.commits];
	}
}

- (IBAction)showGist:(id)sender {
	if (self.delegate && self.event.gist) [self.delegate openEventItem:self.event.gist];
}

#pragma mark Layout

- (CGFloat)normalHeight {
	return 70.0f;
}

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

- (void)positionActionView {
	[super adjustTextViewHeight];
	// position action view at bottom
	CGRect frame = self.actionsView.frame;
	frame.size.width = self.actionsView.subviews.count * 58.0f;
	frame.origin.x = self.frame.size.width / 2 - frame.size.width / 2;
	frame.origin.y = contentTextView.frame.origin.y + contentTextView.frame.size.height;
	if (frame.origin.y < self.normalHeight) frame.origin.y = self.normalHeight;
	self.actionsView.frame = frame;
}

@end