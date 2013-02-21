@class GHComment;

@interface CommentController : UIViewController
- (id)initWithComment:(GHComment *)comment andComments:(id)comments;
@property(nonatomic,strong)NSString *issueNumber;
@property(nonatomic,strong)NSString *issueRepository;
@end