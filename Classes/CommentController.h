@class GHComment;

@interface CommentController : UIViewController
- (id)initWithComment:(GHComment *)comment andComments:(id)comments;
@property(nonatomic,strong)NSString *issueNumber;
@property(nonatomic,strong)NSString *issueRepository;
@property(nonatomic,strong)NSString *pullRequestRepo;
@property(nonatomic,strong)NSString *pullRequestNum;
@property(nonatomic,strong)NSString *gistTitle;
@property(nonatomic,strong)NSString *gistOwner;
@property(nonatomic,strong)NSString *commentType;
//  CommentTypes are NSIntegers which apply to Issue comments, Pull Request comments and Gists comments
//  KEY:
//     Issue Comment: Type 0
//     Pull Request Comment: Type 1
//     Gist Comment: Type 2
@end