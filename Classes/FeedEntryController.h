#import <UIKit/UIKit.h>


@class GHFeedEntry;

@interface FeedEntryController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	GHFeedEntry *entry;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIWebView *contentView;
}

@property(nonatomic,retain) GHFeedEntry *entry;

- (id)initWithFeedEntry:(GHFeedEntry *)theEntry;
- (IBAction)showActions:(id)sender;

@end
