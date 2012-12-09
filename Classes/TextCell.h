@interface TextCell : UITableViewCell
@property(nonatomic,readonly)BOOL hasContent;

- (CGFloat)heightForTableView:(UITableView *)tableView;
- (CGFloat)textWidthForOuterWidth:(CGFloat)outerWidth;
- (void)setContentText:(NSString *)text;
@end