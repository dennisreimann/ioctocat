#import "CommentCell.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "GHUser.h"


@implementation CommentCell

@synthesize comment;
@synthesize gravatarView;
@synthesize userLabel;
@synthesize dateLabel;

- (void)dealloc {
	[comment.user removeObserver:self forKeyPath:kUserGravatarKeyPath];
    [comment release], comment = nil;
	[gravatarView release], gravatarView = nil;
	[userLabel release], userLabel = nil;
	[dateLabel release], dateLabel = nil;
	
	[super dealloc];
}

- (void)setComment:(GHIssueComment *)theComment {
	[theComment retain];
	[comment release];
	comment = theComment;
	
	// Text
	self.userLabel.text = comment.user.login;
	self.dateLabel.text = [comment.updated prettyDate];
	[self setContentText:comment.body];
	
	// Gravatar
	[comment.user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	gravatarView.image = comment.user.gravatar;
	if (!gravatarView.image && !comment.user.isLoaded) [comment.user loadUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath] && comment.user.gravatar) {
		gravatarView.image = comment.user.gravatar;
	}
}

- (CGFloat)height {
	return [super height] + 25;
}

@end
