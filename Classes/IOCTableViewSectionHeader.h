@interface IOCTableViewSectionHeader : UIView
@property(nonatomic,readonly)UILabel *titleLabel;

+ (IOCTableViewSectionHeader *)headerForTableView:(UITableView *)tableView title:(NSString *)title;
@end