#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

@synthesize user;

- (void)dealloc {
	[user removeObserver:self forKeyPath:kGravatarKeyPath];
	[user release], user = nil;
    [userLabel release], userLabel = nil;
    [gravatarView release], gravatarView = nil;
    [super dealloc];
}

- (void)setUser:(GHUser *)aUser {
	[aUser retain];
	[user removeObserver:self forKeyPath:kGravatarKeyPath];
	[user release];
	user = aUser;
	userLabel.text = user.login;
    gravatarView.image = user.gravatar;
	[user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath] && user.gravatar) {
		gravatarView.image = user.gravatar;
	}
}

@end
