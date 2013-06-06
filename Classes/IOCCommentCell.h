#import "IOCTextCell.h"


@class GHComment;

@interface IOCCommentCell : IOCTextCell
@property(nonatomic,strong)GHComment *comment;
@end