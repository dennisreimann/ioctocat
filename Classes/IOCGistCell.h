@class GHGist;

@interface IOCGistCell : UITableViewCell
@property(nonatomic,strong)GHGist *gist;

+ (id)cell;
- (void)hideUser;
@end