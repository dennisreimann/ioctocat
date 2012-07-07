#import "FeedEntryCell.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "GravatarLoader.h"
#import "NSDate+Nibware.h"


@implementation FeedEntryCell

@synthesize entry;

- (void)dealloc {
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release], entry = nil;
	[dateLabel release], dateLabel = nil;
	[titleLabel release], titleLabel = nil;
	[gravatarView release], gravatarView = nil;
	[iconView release], iconView = nil;
    [super dealloc];
}

- (void)setEntry:(GHFeedEntry *)anEntry {
	[entry.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[entry release];
	entry = [anEntry retain];
	titleLabel.text = entry.title;
	// Date
    dateLabel.text = [entry.date prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	[entry.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = entry.user.gravatar;
	if (!gravatarView.image && !entry.user.isLoaded) [entry.user loadData];
}

- (void)setCustomBackgroundColor:(UIColor *)theColor {
    if (!self.backgroundView) {
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        for ( UIView* view in self.contentView.subviews) {
            view.backgroundColor = [UIColor clearColor];
        }
    }
    self.backgroundView.backgroundColor = theColor;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.45 saturation:0.05 brightness:0.9 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && entry.user.gravatar) {
		gravatarView.image = entry.user.gravatar;
	}
}

@end
