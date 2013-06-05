@class GHCollection;

@interface IOCCollectionController : UITableViewController
@property(nonatomic,strong)GHCollection *collection;

- (id)initWithCollection:(GHCollection *)collection;
@end