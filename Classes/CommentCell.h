#import "TextCell.h"


@class GHComment;

@interface CommentCell : TextCell
@property(nonatomic,strong)GHComment *comment;
@end