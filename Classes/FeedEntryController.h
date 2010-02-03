#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry;

@interface FeedEntryController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	GHFeed *feed;
	GHFeedEntry *entry;
	NSUInteger currentIndex;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIWebView *contentView;
	IBOutlet UIBarButtonItem *controlItem;
	IBOutlet UISegmentedControl *navigationControl;
}

@property(nonatomic,retain)GHFeed *feed;
@property(nonatomic,retain)GHFeedEntry *entry;

- (id)initWithFeed:(GHFeed *)theFeed andCurrentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)showActions:(id)sender;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end
