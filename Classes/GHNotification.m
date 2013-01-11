#import "GHResource.h"
#import "GHRepository.h"
#import "GHNotification.h"
#import "NSDictionary+Extensions.h"


@implementation GHNotification

- (id)initWithId:(NSString *)notificationId {
	self = [super init];
	if (self) {
		self.notificationId = notificationId;
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.notificationId = [dict safeStringForKey:@"id"];
	self.updatedAtDate = [dict safeDateForKey:@"updated_at"];
	self.lastReadAtDate = [dict safeDateForKey:@"last_read_at"];
	self.isUnread = [dict safeBoolForKey:@"unread"];
	self.title = [dict safeStringForKeyPath:@"subject.title"];
}

@end
