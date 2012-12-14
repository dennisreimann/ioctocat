#import "TextCell.h"


@protocol EventCellDelegate
- (void)openEventItem:(id)eventItem;
@end


@class GHEvent;

@interface EventCell : TextCell
@property(nonatomic,weak)id<EventCellDelegate> delegate;
@property(nonatomic,strong)GHEvent *event;

- (void)markAsNew;
- (void)markAsRead;
@end