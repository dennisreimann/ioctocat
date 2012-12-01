#import "CommitCell.h"
#import "GHUser.h"
#import "NSDate+Nibware.h"


@implementation CommitCell

+ (id)cell {
	return [self cellWithIdentifier:kCommitCellIdentifier];
}

+ (id)cellWithIdentifier:(id)reuseIdentifier {
	return [[[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.textLabel.font = [UIFont systemFontOfSize:15.0f];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.opaque = YES;
	}
	return self;
}

- (void)dealloc {
	[self.commit.author removeObserver:self forKeyPath:kGravatarKeyPath];
	[_commit release], _commit = nil;
    [super dealloc];
}

- (void)setCommit:(GHCommit *)theCommit {
	[theCommit retain];
	[self.commit.author removeObserver:self forKeyPath:kGravatarKeyPath];
	[_commit release];
	_commit = theCommit;
	
	[self.commit.author addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.imageView.image = self.commit.author.gravatar;
	if (!self.imageView.image && !self.commit.author.gravatarURL) [self.commit.author loadData];
	
    self.textLabel.text = [self shortenMessage:self.commit.message];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", self.commit.author.login, [self shortenSha:self.commit.commitID]];
}

- (NSString *)shortenMessage:(NSString *)longMessage {
	NSArray *comps = [longMessage componentsSeparatedByString:@"\n"];
	return [comps objectAtIndex:0];
}

- (NSString *)shortenSha:(NSString *)longSha {
	return [longSha substringToIndex:6];
}

- (NSString *)shortenRef:(NSString *)longRef {
	return [longRef lastPathComponent];
}

@end
