@class GHResource;

@interface IOCResourceStatusCell : UITableViewCell
@property(nonatomic,strong)NSString *loadingText;
@property(nonatomic,strong)NSString *failedText;
@property(nonatomic,strong)NSString *emptyText;

- (id)initWithResource:(GHResource *)resource name:(NSString *)name;
@end