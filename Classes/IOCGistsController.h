@class GHGists;

@interface IOCGistsController : UITableViewController
@property(nonatomic,assign)BOOL *hideUser;

- (id)initWithGists:(GHGists *)gists;
@end