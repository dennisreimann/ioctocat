#import "IOCTextCell.h"
#import "IOCResourceEditingDelegate.h"


@class GHComment;

@interface IOCCommentCell : IOCTextCell
@property(nonatomic,weak)id<IOCTextCellDelegate, IOCResourceEditingDelegate> delegate;
@property(nonatomic,strong)GHComment *comment;
@end