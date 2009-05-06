#import "FollowCell.h"
#import "GHUser.h"

@implementation FollowCell

@synthesize user;

- (void)setUser:(GHUser *)aUser {
	[user release];
	user = [aUser retain];
	userLabel.text = user.login;
    gravatarView.image = self.user.gravatar;

}

- (void)dealloc {
	[user release];
    [userLabel release];
    [super dealloc];
}

@end
