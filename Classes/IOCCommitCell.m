#import "IOCCommitCell.h"
#import "GHUser.h"
#import "GHCommit.h"
#import "NSDate_IOCExtensions.h"
#import "NSString_IOCExtensions.h"


@implementation IOCCommitCell

static NSString *const AuthorGravatarKeyPath = @"author.gravatar";

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.textLabel.font = [UIFont systemFontOfSize:15.0f];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.layer.cornerRadius = 3;
		self.imageView.layer.masksToBounds = YES;
		self.opaque = YES;
	}
	return self;
}

- (void)dealloc {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect textFrame = self.textLabel.frame;
	CGRect detailFrame = self.detailTextLabel.frame;
	textFrame.origin.x = 50;
	detailFrame.origin.x = 50;
	self.textLabel.frame = textFrame;
	self.detailTextLabel.frame = detailFrame;
	self.imageView.frame = CGRectMake(6, 6, 32, 32);
}

- (void)setCommit:(GHCommit *)commit {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
	_commit = commit;
	[self.commit addObserver:self forKeyPath:AuthorGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.imageView.image = self.commit.author.gravatar ? self.commit.author.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
	self.textLabel.text = self.commit.shortenedMessage;
	NSString *userName = self.commit.author ? self.commit.author.login : self.commit.authorName;
	NSString *dateInfo = self.commit.authoredDate ? [self.commit.authoredDate ioc_prettyDate] : @"";
    NSString *userInfo = ![userName ioc_isEmpty] ? userName : @"";
    NSString *format = [userInfo ioc_isEmpty] || [dateInfo ioc_isEmpty] ? @"%@ - %@%@" : @"%@ - %@ - %@";
    self.detailTextLabel.text = [NSString stringWithFormat:format, self.commit.shortenedSha, userInfo, dateInfo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:AuthorGravatarKeyPath] && self.commit.author.gravatar) {
		self.imageView.image = self.commit.author.gravatar;
	}
}

@end
