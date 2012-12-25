#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@implementation GHComment

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.userLogin];
}

- (void)setValues:(id)dict {
	self.body = [dict safeStringForKey:@"body"];
	self.created = [iOctocat parseDate:[dict safeStringForKey:@"created_at"]];
	self.updated = [iOctocat parseDate:[dict safeStringForKey:@"updated_at"]];
	self.userLogin = [dict safeStringForKeyPath:@"user.login"];
	if (!self.user.gravatarURL) {
		self.user.gravatarURL = [dict safeURLForKeyPath:@"user.avatar_url"];
	}
}

#pragma mark Saving

// Implement this in the subclass
- (void)saveData {
}

@end
