@class GHGist;

@interface IOCGistCell : UITableViewCell
@property(nonatomic,strong)GHGist *gist;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)hideUser;
@end