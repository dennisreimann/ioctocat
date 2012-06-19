#import "GHComment.h"
#import "GHUser.h"


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

#pragma mark Saving

- (void)saveData {
	// Implement this in the subclass
}

@end
