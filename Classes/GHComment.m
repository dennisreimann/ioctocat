#import "GHComment.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation GHComment

@synthesize user;
@synthesize commentID;
@synthesize body;
@synthesize created;
@synthesize updated;

- (void)dealloc {
	[user release], user = nil;
	[body release], body = nil;
	[created release], created = nil;
	[updated release], updated = nil;
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

- (void)saveData {
	// Implement this in the subclass
}

@end
