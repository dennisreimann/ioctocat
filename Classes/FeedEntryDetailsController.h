#import <UIKit/UIKit.h>


@class GHFeedEntry;

@interface FeedEntryDetailsController : UIViewController <UIWebViewDelegate> {
	GHFeedEntry *entry;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIWebView *contentView;
}

@property (nonatomic, retain) GHFeedEntry *entry;

- (id)initWithFeedEntry:(GHFeedEntry *)theEntry;
- (IBAction)showUser:(id)sender;

@end
