#import "IOCTextCell.h"


@class GHEvent;

@interface IOCEventCell : IOCTextCell
@property(nonatomic,strong)GHEvent *event;

- (void)markAsNew;
- (void)markAsRead;
@end