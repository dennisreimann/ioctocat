@interface MenuCell : UITableViewCell
@property(nonatomic,readwrite)NSInteger badgeCount;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
