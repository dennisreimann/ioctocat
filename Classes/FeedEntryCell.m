#import "FeedEntryCell.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GravatarLoader.h"
#import "NSDate+Nibware.h"


@implementation FeedEntryCell

@synthesize entry;

- (void)dealloc {
	[entry.user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[entry release];
	[dateLabel release];
	[titleLabel release];
	[gravatarView release];
	[bgImageView release];
	[iconView release];
    [super dealloc];
}

- (void)setEntry:(GHFeedEntry *)anEntry {
	[entry release];
	entry = [anEntry retain];
	titleLabel.text = entry.title;
	// Date
    dateLabel.text = [entry.date prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	[entry.user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = entry.user.gravatar;
	if (!gravatarView.image && !entry.user.isLoaded) [entry.user loadUser];
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.45 saturation:0.05 brightness:0.9 alpha:1.0];
	dateLabel.backgroundColor = highlightColor;
	titleLabel.backgroundColor = highlightColor;
	bgImageView.backgroundColor = highlightColor;
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	dateLabel.backgroundColor = normalColor;
	titleLabel.backgroundColor = normalColor;
	bgImageView.backgroundColor = normalColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath] && entry.user.gravatar) {
		gravatarView.image = entry.user.gravatar;
	}
}

@end
