#import <UIKit/UIKit.h>
#import "TextCell.h"


@class GHComment;

@interface CommentCell : TextCell
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *userLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;

- (void)setComment:(GHComment *)theComment;
@end