#import "CommitCell.h"
#import "GHUser.h"
#import "NSDate+Nibware.h"


@implementation CommitCell

NSString *const AuthorGravatarKeyPath = @"author.gravatar";

+ (id)cell {
	return [self cellWithIdentifier:kCommitCellIdentifier];
}

+ (id)cellWithIdentifier:(id)reuseIdentifier {
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
		self.opaque = YES;
	}
	return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(4, 4, 36, 36);
}

- (void)dealloc {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
}

- (void)setCommit:(GHCommit *)commit {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
	_commit = commit;
	[self.commit addObserver:self forKeyPath:AuthorGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.imageView.image = self.commit.author.gravatar;
	if (!self.imageView.image && !self.commit.author.gravatarURL) [self.commit.author loadData];
    self.textLabel.text = [self shortenMessage:self.commit.message];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", self.commit.author.login, [self shortenSha:self.commit.commitID]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:AuthorGravatarKeyPath] && self.commit.author.gravatar) {
		self.imageView.image = self.commit.author.gravatar;
	}
}

- (NSString *)shortenMessage:(NSString *)longMessage {
	NSArray *comps = [longMessage componentsSeparatedByString:@"\n"];
	return comps[0];
}

- (NSString *)shortenSha:(NSString *)longSha {
	return [longSha substringToIndex:6];
}

- (NSString *)shortenRef:(NSString *)longRef {
	return [longRef lastPathComponent];
}

@end
