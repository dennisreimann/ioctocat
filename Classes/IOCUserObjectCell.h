@interface IOCUserObjectCell : UITableViewCell
@property(nonatomic,strong)id userObject;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
@end