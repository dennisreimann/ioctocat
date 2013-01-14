#import "GHComment.h"
#import "GHUser.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"


@implementation GHComment

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.userLogin];
}

- (void)setValues:(id)dict {
	self.body = [dict safeStringForKey:@"body"];
	self.created = [dict safeDateForKey:@"created_at"];
	self.updated = [dict safeDateForKey:@"updated_at"];
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
