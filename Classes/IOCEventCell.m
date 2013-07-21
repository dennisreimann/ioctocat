#import "IOCEventCell.h"
#import "GHEvent.h"
#import "GHCommits.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHRepository.h"
#import "GHBranch.h"
#import "GHTag.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "GHPullRequest.h"
#import "NSDate_IOCExtensions.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "TTTAttributedLabel.h"


@interface IOCEventCell () <TTTAttributedLabelDelegate>
@property(nonatomic,weak)IBOutlet UIView *actionsView;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UIButton *gravatarButton;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *titleLabel;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *contentLabel;
@end


@implementation IOCEventCell

static NSString *const UserGravatarKeyPath = @"user.gravatar";

- (void)awakeFromNib {
    [super awakeFromNib];
    self.linksEnabled = NO;
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
	self.dateLabel.text = [self.event.date ioc_prettyDate];
    self.contentLabel.lineBreakMode = self.event.isCommentEvent ? NSLineBreakByTruncatingTail : NSLineBreakByWordWrapping;
	self.contentLabel.numberOfLines = self.event.isCommentEvent ? 3 : 0;
    self.contentText = self.event.contentForDisplay;
	NSString *icon = [NSString stringWithFormat:@"%@.png", self.event.extendedEventType];
	self.iconView.image = [UIImage imageNamed:icon];
	UIImage *gravatar = self.event.user.gravatar ? self.event.user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
    [self.event addObserver:self forKeyPath:UserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self setGravatar:gravatar];
    // actions
    [self linkEventItems];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:UserGravatarKeyPath] && self.event.user.gravatar) {
		[self setGravatar:self.event.user.gravatar];
	}
}

- (void)setContentText:(NSString *)text {
    self.contentLabel.text = text;
    [self adjustContentTextHeight];
}

#pragma mark Helpers

- (void)linkEventItems {
    void (^addLinkToTitle)(NSString *, NSURL *);
    addLinkToTitle = ^(NSString *linkText, NSURL *linkUrl) {
        linkText = [NSString stringWithFormat:@"^%1$@\\s|\\s%1$@\\s|\\s%1$@$", linkText];
        NSRange range = [self.titleLabel.text rangeOfString:linkText options:NSRegularExpressionSearch];
        [self.titleLabel addLinkToURL:linkUrl withRange:range];
    };

    if (self.event.user) {
        addLinkToTitle(self.event.user.login, self.event.user.htmlURL);
    }
    if (self.event.organization) {
        addLinkToTitle(self.event.organization.login, self.event.organization.htmlURL);
    }
    if (self.event.otherUser) {
        addLinkToTitle(self.event.otherUser.login, self.event.otherUser.htmlURL);
    }
    if (self.event.repository) {
        addLinkToTitle(self.event.repository.repoId, self.event.repository.htmlURL);
    }
    if (self.event.otherRepository) {
        addLinkToTitle(self.event.otherRepository.repoId, self.event.otherRepository.htmlURL);
    }
    if (self.event.issue && !self.event.pullRequest) {
        addLinkToTitle(self.event.issue.repoIdWithIssueNumber, self.event.issue.htmlURL);
    }
    if (self.event.pullRequest) {
        addLinkToTitle(self.event.pullRequest.repoIdWithIssueNumber, self.event.pullRequest.htmlURL);
    }
    if (self.event.gist) {
        addLinkToTitle([NSString stringWithFormat:@"gist %@", self.event.gist.gistId], self.event.gist.htmlURL);
    }
    if (self.event.commits && self.event.commits.count > 0) {
        GHCommit *commit = self.event.commits[0];
        addLinkToTitle(commit.shortenedSha, commit.htmlURL);
        //commits
        for (GHCommit *commit in self.event.commits.items) {
            NSRange range = [self.contentLabel.text rangeOfString:commit.shortenedSha];
            [self.contentLabel addLinkToURL:commit.htmlURL withRange:range];
        }
    }
    if (self.event.pages) {
        NSDictionary *wiki = self.event.pages[0];
        NSString *pageName = [wiki ioc_stringForKey:@"page_name"];
        NSURL *htmlURL = [wiki ioc_URLForKey:@"html_url"];
        addLinkToTitle([NSString stringWithFormat:@"\"%@\"", pageName], htmlURL);
    }
    if (self.event.branch) {
        addLinkToTitle(self.event.ref, self.event.branch.htmlURL);
    }
    if (self.event.tag) {
        addLinkToTitle(self.event.ref, self.event.tag.htmlURL);
    }
}

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
    self.iconView.backgroundColor = color;
    self.gravatarButton.backgroundColor = color;
    self.contentLabel.backgroundColor = color;
    self.titleLabel.backgroundColor = color;
    self.dateLabel.backgroundColor = color;
}

- (void)setGravatar:(UIImage *)gravatar {
    [self.gravatarButton setImage:gravatar forState:UIControlStateNormal];
    [self.gravatarButton setImage:gravatar forState:UIControlStateHighlighted];
    [self.gravatarButton setImage:gravatar forState:UIControlStateSelected];
    [self.gravatarButton setImage:gravatar forState:UIControlStateDisabled];
}

#pragma mark Actions

- (IBAction)openActor:(id)sender {
    if (!self.event.read) [self markAsRead];
    if ([self.delegate respondsToSelector:@selector(openURL:)]) {
        [self.delegate openURL:self.event.user.htmlURL];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (!self.event.read) [self markAsRead];
    [super attributedLabel:label didSelectLinkWithURL:url];
}

#pragma mark Layout

- (CGFloat)heightWithoutContentText {
	return 70.0f;
}

- (CGFloat)contentTextMarginTop {
	return 0.0f;
}

@end