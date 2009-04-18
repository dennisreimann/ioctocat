#import "GHFeedEntryCell.h"
#import "GHFeedEntry.h"
#import "GHUser.h"
#import "Gravatar.h"


@implementation GHFeedEntryCell

- (void)setEntry:(GHFeedEntry *)anEntry {
	[entry release];
	entry = [anEntry retain];
	titleLabel.text = entry.title;
	// Date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:entry.date];
	[dateFormatter release];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", entry.eventType];
	iconView.image = [UIImage imageNamed:icon];
	// Gravatar
	gravatarView.image = entry.user.gravatar.image;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[entry release];
	[dateLabel release];
	[titleLabel release];
	[contentLabel release];
	[gravatarView release];
	[iconView release];
    [super dealloc];
}

@end
