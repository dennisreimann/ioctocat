#import <UIKit/UIKit.h>


@class GHFeedEntry;

@interface FeedEntryCell : UITableViewCell {
	GHFeedEntry *entry;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
}

@property (nonatomic, retain) GHFeedEntry *entry;

@end
