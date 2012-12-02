#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)setUser:(GHUser *)aUser {
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
	_user = aUser;
	self.userLabel.text = self.user.login;
	self.gravatarView.image = self.user.gravatar;
	[self.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && self.user.gravatar) {
		self.gravatarView.image = self.user.gravatar;
	}
}

@end