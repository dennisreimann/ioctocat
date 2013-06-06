@class GHFiles;

@interface IOCFilesCell : UITableViewCell
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)NSString *description;

- (void)setFiles:(GHFiles *)files andDescription:(NSString *)description;
@end