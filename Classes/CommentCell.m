#import "CommentCell.h"
#import "GHComment.h"
#import "NSDate+Nibware.h"
#import "GHUser.h"


@interface CommentCell ()
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *userLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@end


@implementation CommentCell

static NSString *const UserGravatarKeyPath = @"user.gravatar";

- (void)awakeFromNib {
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

- (void)dealloc {
	[self.comment removeObserver:self forKeyPath:UserGravatarKeyPath];
}

- (CGFloat)marginTop {
	return 0.0f;
}

- (CGFloat)marginRight {
	return 1.0f;
}

- (CGFloat)marginBottom {
	return 3.0f;
}

- (CGFloat)marginLeft {
	return 1.0f;
}

- (void)setComment:(GHComment *)comment {
	[self.comment removeObserver:self forKeyPath:UserGravatarKeyPath];
	_comment = comment;
	// Text
	self.userLabel.text = self.comment.user.login;
    self.dateLabel.text = [self.comment.createdAt prettyDate];
	[self setContentText:self.comment.body];
	// Gravatar
	[self.comment addObserver:self forKeyPath:UserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.gravatarView.image = self.comment.user.gravatar ? self.comment.user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:UserGravatarKeyPath] && self.comment.user.gravatar) {
		self.gravatarView.image = self.comment.user.gravatar;
	}
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	return [super heightForTableView:tableView] + 30.0f; // the header is 30px high
}

@end