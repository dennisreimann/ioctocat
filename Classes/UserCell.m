#import "UserCell.h"
#import "GHUser.h"


@implementation UserCell

@synthesize user;

- (void)setUser:(GHUser *)aUser {
	[user release];
	user = [aUser retain];
	userLabel.text = user.login;
    gravatarView.image = user.gravatar;
}

- (void)dealloc {
	[user release];
    [userLabel release];
    [super dealloc];
}

@end
