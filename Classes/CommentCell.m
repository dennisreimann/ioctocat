#import "CommentCell.h"
#import "GHComment.h"
#import "NSDate+Nibware.h"
#import "GHUser.h"


@implementation CommentCell

@synthesize comment;
@synthesize gravatarView;
@synthesize userLabel;
@synthesize dateLabel;

- (void)dealloc {
	[comment.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[comment release], comment = nil;
	[gravatarView release], gravatarView = nil;
	[userLabel release], userLabel = nil;
	[dateLabel release], dateLabel = nil;
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
	[comment.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[comment release];
	comment = theComment;
	// Text
	self.userLabel.text = comment.user.login;
	self.dateLabel.text = [comment.updated prettyDate];
	[self setContentText:comment.body];
	// Gravatar
	[comment.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = comment.user.gravatar;
	if (!gravatarView.image && !comment.user.gravatarURL) [comment.user loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && comment.user.gravatar) {
		gravatarView.image = comment.user.gravatar;
	}
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	return [super heightForTableView:tableView] + 30.0f; // the header is 30px high
}

@end