#import <UIKit/UIKit.h>
#import "TextCell.h"


@class GHComment;

@interface CommentCell : TextCell {
	GHComment *comment;
	UIImageView *gravatarView;
	UILabel *userLabel;
	UILabel *dateLabel;
}

@property(nonatomic,retain)GHComment *comment;
@property(nonatomic,retain)IBOutlet UIImageView *gravatarView;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;
@property(nonatomic,retain)IBOutlet UILabel *dateLabel;

- (void)setComment:(GHComment *)theComment;

@end
