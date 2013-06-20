@interface IOCLabeledCell : UITableViewCell
@property(nonatomic,strong)NSString *emptyText;
@property(nonatomic,readonly)BOOL hasContent;

- (void)setLabelText:(NSString *)text;
- (void)setContentText:(NSString *)text;
@end