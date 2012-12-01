#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_user release], _user = nil;
	[_userLabel release], _userLabel = nil;
	[_gravatarView release], _gravatarView = nil;
	[super dealloc];
}

- (void)setUser:(GHUser *)aUser {
	[aUser retain];
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[_user release];
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