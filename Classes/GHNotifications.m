#import "AFHTTPRequestOperation.h"
#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"


@implementation GHNotifications

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	self.byRepository = [NSMutableDictionary dictionary];
	for (id dict in values) {
		GHNotification *notification = [[GHNotification alloc] initWithDict:dict];
		if ([notification.lastReadAtDate compare:self.lastUpdate] != NSOrderedDescending) {
			[notification markAsRead];
		}
		[self addObject:notification];
		if (!self.byRepository[notification.repository.repoId]) {
			self.byRepository[notification.repository.repoId] = [NSMutableArray array];
		}
		[self.byRepository[notification.repository.repoId] addObject:notification];
	}
	self.lastUpdate = [NSDate date];
}

- (void)setHeaderValues:(NSDictionary *)values {
	[super setHeaderValues:values];
	self.pollInterval = [values safeIntegerForKey:@"X-Poll-Interval"];
}

@end