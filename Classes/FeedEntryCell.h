#import <UIKit/UIKit.h>


@class GHFeedEntry;

@interface FeedEntryCell : UITableViewCell {
	GHFeedEntry *entry;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIImageView *bgImageView;
}

@property (nonatomic, retain) GHFeedEntry *entry;

- (void)markAsNew;
- (void)markAsRead;

@end
