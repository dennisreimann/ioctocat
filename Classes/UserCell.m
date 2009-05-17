#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

@synthesize user;

- (void)dealloc {
	[user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[user release];
    [userLabel release];
    [gravatarView release];
    [super dealloc];
}

- (void)setUser:(GHUser *)aUser {
	[aUser retain];
	[user release];
	user = aUser;
	userLabel.text = user.login;
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
    gravatarView.image = user.gravatar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
		gravatarView.image = user.gravatar;
	}
}

@end
