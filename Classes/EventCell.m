#import "EventCell.h"
#import "GHEvent.h"
#import "GHCommits.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "NSDate+Nibware.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "TTTAttributedLabel.h"


@interface EventCell () <TTTAttributedLabelDelegate>
@property(nonatomic,weak)IBOutlet UIView *actionsView;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UIButton *gravatarButton;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *titleLabel;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *contentLabel;
@end


@implementation EventCell

static NSString *const UserGravatarKeyPath = @"user.gravatar";

- (void)awakeFromNib {
    [super awakeFromNib];
    self.linksEnabled = NO;
    self.emojiEnabled = YES;
    self.markdownEnabled = NO;
    UIColor *linkColor = [UIColor colorWithRed:0.203 green:0.441 blue:0.768 alpha:1.000];
    self.gravatarButton.layer.cornerRadius = 3;
    self.gravatarButton.layer.masksToBounds = YES;
    self.titleLabel.delegate = self;
    self.titleLabel.linkAttributes = [NSDictionary dictionaryWithObjects:@[@NO, (id)linkColor.CGColor] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    self.titleLabel.activeLinkAttributes = [NSDictionary dictionaryWithObjects:@[@YES, (id)linkColor.CGColor] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    self.contentLabel.linkAttributes = [NSDictionary dictionaryWithObjects:@[@NO, (id)[linkColor CGColor], [UIFont fontWithName:@"Courier" size:14.0f]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName, (NSString *)kCTFontAttributeName]];
    self.contentLabel.activeLinkAttributes = [NSDictionary dictionaryWithObjects:@[@YES, (id)[linkColor CGColor], [UIFont fontWithName:@"Courier" size:14.0f]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName, (NSString *)kCTFontAttributeName]];
}

- (void)dealloc {
	[self.event removeObserver:self forKeyPath:UserGravatarKeyPath];
}

- (void)setEvent:(GHEvent *)event {
    if (event == self.event) return;
	[self.event removeObserver:self forKeyPath:UserGravatarKeyPath];
	_event = event;
	self.titleLabel.text = self.event.title;
	self.dateLabel.text = [self.event.date prettyDate];
    self.truncationLength = self.event.isCommentEvent ? 160 : 0;
    self.contentText = self.event.content;
	NSString *icon = [NSString stringWithFormat:@"%@.png", self.event.extendedEventType];
	self.iconView.image = [UIImage imageNamed:icon];
	UIImage *gravatar = self.event.user.gravatar ? self.event.user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
    [self.event addObserver:self forKeyPath:UserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self setGravatar:gravatar];
    // actions
    if (self.event.user) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.user.login];
        [self.titleLabel addLinkToURL:self.event.user.htmlURL withRange:range];
    }
    if (self.event.organization) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.organization.login];
        [self.titleLabel addLinkToURL:self.event.organization.htmlURL withRange:range];
    }
    if (self.event.otherUser) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.otherUser.login];
        [self.titleLabel addLinkToURL:self.event.otherUser.htmlURL withRange:range];
    }
    if (self.event.repository) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.repository.repoId];
        [self.titleLabel addLinkToURL:self.event.repository.htmlURL withRange:range];
    }
    if (self.event.otherRepository) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.otherRepository.repoId];
        [self.titleLabel addLinkToURL:self.event.otherRepository.htmlURL withRange:range];
    }
    if (self.event.issue && !self.event.pullRequest) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.issue.repoIdWithIssueNumber];
        [self.titleLabel addLinkToURL:self.event.issue.htmlURL withRange:range];
    }
    if (self.event.pullRequest) {
        NSRange range = [self.titleLabel.text rangeOfString:self.event.pullRequest.repoIdWithIssueNumber];
        [self.titleLabel addLinkToURL:self.event.pullRequest.htmlURL withRange:range];
    }
    if (self.event.gist) {
        NSRange range = [self.titleLabel.text rangeOfString:[NSString stringWithFormat:@"gist %@", self.event.gist.gistId]];
        [self.titleLabel addLinkToURL:self.event.gist.htmlURL withRange:range];
    }
    if (self.event.commits) {
        GHCommit *commit = self.event.commits[0];
        NSRange range = [self.titleLabel.text rangeOfString:commit.shortenedSha];
        [self.titleLabel addLinkToURL:commit.htmlURL withRange:range];
        // commits
        for (GHCommit *commit in self.event.commits.items) {
            NSRange range = [self.contentLabel.text rangeOfString:commit.shortenedSha];
            [self.contentLabel addLinkToURL:commit.htmlURL withRange:range];
        }
    }
    if (self.event.pages) {
        NSDictionary *wiki = self.event.pages[0];
        NSString *pageName = [wiki safeStringForKey:@"page_name"];
        NSURL *htmlURL = [wiki safeURLForKey:@"html_url"];
        NSRange range = [self.titleLabel.text rangeOfString:[NSString stringWithFormat:@"\"%@\"", pageName]];
        [self.titleLabel addLinkToURL:htmlURL withRange:range];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:UserGravatarKeyPath] && self.event.user.gravatar) {
		[self setGravatar:self.event.user.gravatar];
	}
}

#pragma mark Helpers

- (void)markAsNew {
	UIColor *color = [UIColor colorWithHue:0.6 saturation:0.09 brightness:1.0 alpha:1.0];
	[self setCustomBackgroundColor:color];
}

- (void)markAsRead {
	UIColor *color = [UIColor whiteColor];
	[self setCustomBackgroundColor:color];
	[self.event markAsRead];
}

- (void)setCustomBackgroundColor:(UIColor *)color {
	if (!self.backgroundView) self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	self.backgroundView.backgroundColor = color;
}

- (void)setGravatar:(UIImage *)gravatar {
    [self.gravatarButton setImage:gravatar forState:UIControlStateNormal];
    [self.gravatarButton setImage:gravatar forState:UIControlStateHighlighted];
    [self.gravatarButton setImage:gravatar forState:UIControlStateSelected];
    [self.gravatarButton setImage:gravatar forState:UIControlStateDisabled];
}

#pragma mark Actions

- (IBAction)openActor:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openURL:)]) {
        [self.delegate openURL:self.event.user.htmlURL];
    }
}

#pragma mark Layout

- (CGFloat)heightWithoutContentText {
	return 70.0f;
}

- (CGFloat)contentTextMarginTop {
	return 0.0f;
}

@end