@class GHCollection, GHUser, IOCResourceStatusCell;

@interface IOCCollectionController : UITableViewController
@property(nonatomic,strong)GHCollection *collection;
@property(nonatomic,readonly)GHUser *currentUser;

- (id)initWithCollection:(GHCollection *)collection;
@end

@interface IOCCollectionController (Protected)
- (IOCResourceStatusCell *)statusCell;
- (BOOL)canReload;
- (void)displayCollection;
- (void)loadCollection;
@end