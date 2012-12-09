@interface FilesCell : UITableViewCell
@property(nonatomic,strong)NSArray *files;
@property(nonatomic,strong)NSString *description;

- (void)setFiles:(NSArray *)theFiles andDescription:(NSString *)theDescription;
@end