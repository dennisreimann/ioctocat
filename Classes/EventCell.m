#import "EventCell.h"
#import "GHEvent.h"
#import "GHCommits.h"
#import "GHUser.h"
#import "IOCAvatarLoader.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "NSDate+Nibware.h"


@interface EventCell ()
@property(nonatomic,weak)IBOutlet UIView *actionsView;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UITextView *contentTextView;
@property(nonatomic,strong)IBOutlet UIButton *repositoryButton;
@property(nonatomic,strong)IBOutlet UIButton *otherRepositoryButton;
@property(nonatomic,strong)IBOutlet UIButton *userButton;
@property(nonatomic,strong)IBOutlet UIButton *otherUserButton;
@property(nonatomic,strong)IBOutlet UIButton *organizationButton;
@property(nonatomic,strong)IBOutlet UIButton *issueButton;
@property(nonatomic,strong)IBOutlet UIButton *pullRequestButton;
@property(nonatomic,strong)IBOutlet UIButton *wikiButton;
@property(nonatomic,strong)IBOutlet UIButton *commitButton;
@property(nonatomic,strong)IBOutlet UIButton *gistButton;
@end


@implementation EventCell

- (void)awakeFromNib {
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

- (void)dealloc {
	[self.event.user removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)setEvent:(GHEvent *)event {
	[self.event.user removeObserver:self forKeyPath:kGravatarKeyPath];
	_event = event;
	self.titleLabel.text = self.event.title;
	self.dateLabel.text = [self.event.date prettyDate];
	// Truncate long comments
	NSString *text = self.event.content;
	if (self.event.isCommentEvent) {
		NSInteger truncateLength = 175;
		if (text.length > truncateLength) {
			NSRange range = {0, truncateLength};
			text = [NSString stringWithFormat:@"%@ […]", [self.event.content substringWithRange:range]];
		}
		[self setContentText:text];
	} else {
		[self setContentText:text];
	}
	NSString *icon = [NSString stringWithFormat:@"%@.png", self.event.extendedEventType];
	self.iconView.image = [UIImage imageNamed:icon];
	[self.event.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.gravatarView.image = self.event.user.gravatar ? self.event.user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
	if (!self.event.user.gravatarURL) {
		[self.event.user loadData];
	}
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

- (void)setCustomBackgroundColor:(UIColor *)color {
	if (!self.backgroundView) {
		self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	self.backgroundView.backgroundColor = color;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.586 saturation:0.087 brightness:1.0 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
	[self.event markAsRead];
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

- (void)adjustTextViewHeight {
	CGRect frame = self.contentTextView.frame;
	frame.size.height = self.hasContent ? self.contentTextView.contentSize.height + self.textInset : 0.0f;
	self.contentTextView.frame = frame;
}

#pragma mark Layout

- (CGFloat)textInset {
	return 8.0f; // UITextView has an inset of 8px on each side
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
	NSDictionary *wiki = (self.event.pages)[0];
	if (self.delegate && wiki) [self.delegate openEventItem:wiki];
}

- (IBAction)showCommit:(id)sender {
	if (self.event.commits.count == 1) {
		GHCommit *commit = self.event.commits[0];
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
	[self adjustTextViewHeight];
	// position action view at bottom
	CGRect frame = self.actionsView.frame;
	frame.size.width = self.actionsView.subviews.count * 58.0f;
	frame.origin.x = self.frame.size.width / 2 - frame.size.width / 2;
	frame.origin.y = self.contentTextView.frame.origin.y + self.contentTextView.frame.size.height;
	if (frame.origin.y < self.normalHeight) frame.origin.y = self.normalHeight;
	self.actionsView.frame = frame;
}

@end