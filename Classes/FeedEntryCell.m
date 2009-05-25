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
	(entry.user.gravatar) ? [gravatarView setImage:entry.user.gravatar] : [entry.user loadUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath] && entry.user.gravatar) {
		gravatarView.image = entry.user.gravatar;
	}
}

@end
