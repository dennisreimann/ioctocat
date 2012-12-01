#import "CommentCell.h"
#import "GHComment.h"
#import "NSDate+Nibware.h"
#import "GHUser.h"


@implementation CommentCell

- (void)dealloc {
	[self.comment.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_comment release], _comment = nil;
	[_gravatarView release], _gravatarView = nil;
	[_userLabel release], _userLabel = nil;
	[_dateLabel release], _dateLabel = nil;
	[super dealloc];
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

- (void)setComment:(GHComment *)theComment {
	[theComment retain];
	[self.comment.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_comment release];
	_comment = theComment;
	// Text
	self.userLabel.text = self.comment.user.login;
	self.dateLabel.text = [self.comment.updated prettyDate];
	[self setContentText:self.comment.body];
	// Gravatar
	[self.comment.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.gravatarView.image = self.comment.user.gravatar;
	if (!self.gravatarView.image && !self.comment.user.gravatarURL) [self.comment.user loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && self.comment.user.gravatar) {
		self.gravatarView.image = self.comment.user.gravatar;
	}
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	return [super heightForTableView:tableView] + 30.0f; // the header is 30px high
}

@end