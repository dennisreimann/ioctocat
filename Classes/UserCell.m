#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

@synthesize user;

- (void)setUser:(GHUser *)aUser {
	[aUser retain];
	[user release];
	user = aUser;
	userLabel.text = user.login;
    gravatarView.image = user.gravatar;
}

- (void)dealloc {
	[user release];
    [userLabel release];
    [gravatarView release];
    [super dealloc];
}

@end
