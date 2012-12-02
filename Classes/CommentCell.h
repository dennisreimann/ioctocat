#import <UIKit/UIKit.h>
#import "TextCell.h"


@class GHComment;

@interface CommentCell : TextCell

@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,strong)IBOutlet UIImageView *gravatarView;
@property(nonatomic,strong)IBOutlet UILabel *userLabel;
@property(nonatomic,strong)IBOutlet UILabel *dateLabel;

- (void)setComment:(GHComment *)theComment;

@end