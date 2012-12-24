#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@implementation GHComment

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.userLogin];
}

- (void)setUserWithValues:(NSDictionary *)dict {
	self.userLogin = [dict safeStringForKey:@"login"];
	if (!self.user.gravatarURL) {
		self.user.gravatarURL = [dict safeURLForKey:@"avatar_url"];
	}
}

#pragma mark Saving

// Implement this in the subclass
- (void)saveData {
}

@end
