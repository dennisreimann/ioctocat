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
#import "NSString+Emojize.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "TTTAttributedLabel.h"


@interface EventCell () <TTTAttributedLabelDelegate>
@property(nonatomic,weak)IBOutlet UIView *actionsView;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *titleLabel;
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *contentLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UIButton *gravatarButton;
@end


@implementation EventCell

static NSString *const UserGravatarKeyPath = @"user.gravatar";

- (void)awakeFromNib {
    UIColor *linkColor = [UIColor colorWithRed:0.203 green:0.441 blue:0.768 alpha:1.000];
	self.gravatarButton.layer.cornerRadius = 3;
	self.gravatarButton.layer.masksToBounds = YES;
    self.titleLabel.delegate = self;
    self.contentLabel.delegate = self;
    self.titleLabel.linkAttributes = [NSDictionary dictionaryWithObjects:@[@NO, (id)[linkColor CGColor]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    self.titleLabel.activeLinkAttributes = [NSDictionary dictionaryWithObjects:@[@YES, (id)[linkColor CGColor]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];;
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
	// Truncate long comments
	NSString *text = [self.event.content emojizedString];
    if (self.event.isCommentEvent) {
		NSInteger truncateLength = 160;
		if (text.length > truncateLength) {
			NSRange range = {0, truncateLength};
			text = [NSString stringWithFormat:@"%@…", [self.event.content substringWithRange:range]];
		}
	}
    self.contentLabel.text = text;
    [self adjustContentTextHeight];
	NSString *icon = [NSString stringWithFormat:@"%@.png", self.event.extendedEventType];
	self.iconView.image = [UIImage imageNamed:icon];
	[self.event addObserver:self forKeyPath:UserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	UIImage *gravatar = self.event.user.gravatar ? self.event.user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
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

- (void)setCustomBackgroundColor:(UIColor *)color {
	if (!self.backgroundView) {
		self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	self.backgroundView.backgroundColor = color;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.6 saturation:0.09 brightness:1.0 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
	[self.event markAsRead];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:UserGravatarKeyPath] && self.event.user.gravatar) {
		[self setGravatar:self.event.user.gravatar];
	}
}

- (void)adjustContentTextHeight {
	CGRect frame = self.contentLabel.frame;
    CGSize size = [self contentTextSizeForWidth:frame.size.width];
	frame.size.height = size.height;
	self.contentLabel.frame = frame;
}

#pragma mark Layout

- (void)layoutSubviews {
	[super layoutSubviews];
	[self adjustContentTextHeight];
}

- (CGFloat)marginTop {
	return 73.0f;
}

- (CGFloat)marginRight {
	return 9.0f;
}

- (CGFloat)marginBottom {
	return 10.0f;
}

- (CGFloat)marginLeft {
	return 9.0f;
}

- (CGSize)contentTextSizeForWidth:(CGFloat)width {
    CGFloat maxHeight = 50000.0f;
	CGSize constraint = CGSizeMake(width, maxHeight);
    return [self.contentLabel.text sizeWithFont:self.contentLabel.font constrainedToSize:constraint lineBreakMode:self.contentLabel.lineBreakMode];
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
    if ([self.contentLabel.text isEmpty]) return 70.0f;
    // calculate the outer width of the cell based on the tableView style
	CGFloat width = tableView.frame.size.width;
	if (tableView.style == UITableViewStyleGrouped) {
		// on the iPhone the inset is 20px, on the iPad 90px
		width -= [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 20.0f : 90.0f;
	}
    CGFloat marginH = self.marginLeft + self.marginRight;
	CGFloat marginV = self.marginTop + self.marginBottom;
    width -= marginH;
	CGSize size = [self contentTextSizeForWidth:width];
	return size.height + marginV;
}

- (void)setGravatar:(UIImage *)gravatar {
    [self.gravatarButton setImage:gravatar forState:UIControlStateNormal];
    [self.gravatarButton setImage:gravatar forState:UIControlStateHighlighted];
    [self.gravatarButton setImage:gravatar forState:UIControlStateSelected];
    [self.gravatarButton setImage:gravatar forState:UIControlStateDisabled];
}

#pragma mark Actions

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (self.delegate && url) [self.delegate openEventItemWithGitHubURL:url];
}

- (IBAction)openActor:(id)sender {
    if (self.delegate) [self.delegate openEventItemWithGitHubURL:self.event.user.htmlURL];
}

@end