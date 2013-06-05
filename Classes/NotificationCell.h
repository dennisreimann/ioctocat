@class GHNotification;

@interface NotificationCell : UITableViewCell
@property(nonatomic,strong)GHNotification *notification;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)markAsNew;
- (void)markAsRead;
@end