#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation GHComment

- (void)dealloc {
	[_user release], _user = nil;
	[_body release], _body = nil;
	[_created release], _created = nil;
	[_updated release], _updated = nil;
	[super dealloc];
}

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
