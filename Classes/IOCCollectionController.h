@class GHCollection, IOCResourceStatusCell;

@interface IOCCollectionController : UITableViewController
@property(nonatomic,strong)GHCollection *collection;

- (id)initWithCollection:(GHCollection *)collection;
@end

@interface IOCCollectionController (Protected)
- (IOCResourceStatusCell *)statusCell;
- (BOOL)canReload;
- (void)displayCollection;
- (void)loadCollection;
@end