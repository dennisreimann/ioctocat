@class GHNotification;

@interface NotificationCell : UITableViewCell
@property(nonatomic,strong)GHNotification *notification;

+ (id)cell;
@end