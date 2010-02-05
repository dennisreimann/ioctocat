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
	IBOutlet UISegmentedControl *navigationControl;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *controlItem;
	IBOutlet UIBarButtonItem *webItem;
	IBOutlet UIBarButtonItem *repositoryItem;
	IBOutlet UIBarButtonItem *firstUserItem;
	IBOutlet UIBarButtonItem *secondUserItem;
	IBOutlet UIBarButtonItem *issueItem;
}

@property(nonatomic,retain)GHFeed *feed;
@property(nonatomic,retain)GHFeedEntry *entry;

- (id)initWithFeed:(GHFeed *)theFeed andCurrentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;
- (IBAction)showInWebView:(id)sender;
- (IBAction)showRepository:(id)sender;
- (IBAction)showFirstUser:(id)sender;
- (IBAction)showSecondUser:(id)sender;
- (IBAction)showIssue:(id)sender;

@end
