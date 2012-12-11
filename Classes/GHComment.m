#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation GHComment

- (void)setUserWithValues:(NSDictionary *)userDict {
	self.user = [[iOctocat sharedInstance] userWithLogin:[userDict valueForKey:@"login"]];
	NSString *avatarURL = [userDict valueForKey:@"avatar_url"];
	if (!self.user.gravatarURL && ![avatarURL isEmpty]) {
		self.user.gravatarURL = [NSURL smartURLFromString:avatarURL];
	}
}

#pragma mark Saving

// Implement this in the subclass
- (void)saveData {
}

@end
