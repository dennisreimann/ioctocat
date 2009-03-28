#import <UIKit/UIKit.h>


@class GHFeedEntry;

@interface GHFeedEntryCell : UITableViewCell {
  @private
	GHFeedEntry *entry;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *contentLabel;
	IBOutlet UIImageView *iconView;
}

- (void)setEntry:(GHFeedEntry *)anEntry;

@end
