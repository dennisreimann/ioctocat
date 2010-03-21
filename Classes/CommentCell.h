#import <UIKit/UIKit.h>
#import "TextCell.h"


@class GHIssueComment;

@interface CommentCell : TextCell {
	GHIssueComment *comment;
	UIImageView *gravatarView;
	UILabel *userLabel;
	UILabel *dateLabel;
}

@property(nonatomic,retain)GHIssueComment *comment;
@property(nonatomic,retain)IBOutlet UIImageView *gravatarView;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;
@property(nonatomic,retain)IBOutlet UILabel *dateLabel;

- (void)setComment:(GHIssueComment *)theComment;

@end
