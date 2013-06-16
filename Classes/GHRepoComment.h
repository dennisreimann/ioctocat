#import "GHResource.h"
#import "GHComment.h"


@class GHRepository, GHUser;

@interface GHRepoComment : GHComment
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,assign)NSUInteger position;
@property(nonatomic,assign)NSUInteger line;

- (id)initWithRepo:(GHRepository *)repo;
@end