@class GHGist;

@interface GistCell : UITableViewCell
@property(nonatomic,strong)GHGist *gist;

+ (id)cell;
@end