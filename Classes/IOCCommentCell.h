#import "IOCTextCell.h"


@class GHComment, GHUser;

@protocol IOCCommentCellDelegate <NSObject>
- (GHUser *)currentUser;
@optional
- (void)editComment:(GHComment *)comment;
- (void)deleteComment:(GHComment *)comment;
@end

@interface IOCCommentCell : IOCTextCell
@property(nonatomic,weak)id<IOCTextCellDelegate, IOCCommentCellDelegate> delegate;
@property(nonatomic,strong)GHComment *comment;
@end