@interface LabeledCell : UITableViewCell
@property(nonatomic,readonly)BOOL hasContent;

- (void)setLabelText:(NSString *)text;
- (void)setContentText:(NSString *)text;
@end