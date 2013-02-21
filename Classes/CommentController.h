@class GHComment;

@interface CommentController : UIViewController<UIAlertViewDelegate>
- (id)initWithComment:(GHComment *)comment andComments:(id)comments;
@property(nonatomic,strong)NSString *issueNumber;
@property(nonatomic,strong)NSString *issueRepository;
@end