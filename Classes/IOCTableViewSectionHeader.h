@interface IOCTableViewSectionHeader : UIView
@property(nonatomic,readonly)UILabel *titleLabel;

+ (instancetype)headerForTableView:(UITableView *)tableView title:(NSString *)title;
@end