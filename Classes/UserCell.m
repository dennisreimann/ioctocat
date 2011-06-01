#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

@synthesize user;

- (void)dealloc {
	[user release];
    [userLabel release];
    [gravatarView release];
    [super dealloc];
}

- (void)viewWillAppear: (BOOL)animated {
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];    
}

- (void)viewWillDisappear: (BOOL)animated {
	[user removeObserver:self forKeyPath:kUserGravatarKeyPath];
}

- (void)setUser:(GHUser *)aUser {
	[aUser retain];
	[user release];
	user = aUser;
	userLabel.text = user.login;
    gravatarView.image = user.gravatar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath] && user.gravatar) {
		gravatarView.image = user.gravatar;
	}
}

@end
