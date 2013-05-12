#import "TextCell.h"


@class GHEvent;

@interface EventCell : TextCell
@property(nonatomic,strong)GHEvent *event;

- (void)markAsNew;
- (void)markAsRead;
@end