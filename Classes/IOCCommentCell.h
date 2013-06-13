#import "IOCTextCell.h"


@class GHComment;

@protocol IOCCommentCellDelegate <NSObject>
- (BOOL)canManageComment:(GHComment *)comment;
- (void)editComment:(GHComment *)comment;
- (void)deleteComment:(GHComment *)comment;
@end

@interface IOCCommentCell : IOCTextCell
@property(nonatomic,weak)id<IOCTextCellDelegate, IOCCommentCellDelegate> delegate;
@property(nonatomic,strong)GHComment *comment;
@end