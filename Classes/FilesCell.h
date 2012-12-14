@interface FilesCell : UITableViewCell
@property(nonatomic,strong)NSArray *files;
@property(nonatomic,strong)NSString *description;

- (void)setFiles:(NSArray *)files andDescription:(NSString *)description;
@end