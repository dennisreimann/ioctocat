#import "TextCell.h"


@protocol EventCellDelegate <NSObject>
- (void)openEventItemWithGitHubURL:(id)eventItem;
@end


@class GHEvent;

@interface EventCell : UITableViewCell
@property(nonatomic,weak)id<EventCellDelegate> delegate;
@property(nonatomic,strong)GHEvent *event;

- (void)markAsNew;
- (void)markAsRead;
- (CGFloat)heightForTableView:(UITableView *)tableView;
@end