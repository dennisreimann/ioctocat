#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation GHComment

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.userLogin];
}

- (void)setUserWithValues:(NSDictionary *)userDict {
	self.userLogin = userDict[@"login"];
	NSString *avatarURL = userDict[@"avatar_url"];
	if (!self.user.gravatarURL && ![avatarURL isEmpty]) {
		self.user.gravatarURL = [NSURL smartURLFromString:avatarURL];
	}
}

#pragma mark Saving

// Implement this in the subclass
- (void)saveData {
}

@end
