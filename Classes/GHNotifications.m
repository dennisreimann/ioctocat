#import "AFHTTPRequestOperation.h"
#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"
#import "IOCDefaultsPersistence.h"


@implementation GHNotifications

- (id)initWithPath:(NSString *)path {
	if (self = [super initWithPath:path]) {
		self.notificationsCount = 0;
		self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:self.resourcePath];
	}
	return self;
}

- (NSURLRequestCachePolicy)cachePolicy {
	if (self.pollInterval) {
		// If there is a polling interval give by GitHub respect it:
		// Only reload in case the last update has passed the interval,
		// otherwise use the cached data (default cache policy)
		NSDate *threshold = [self.lastUpdate dateByAddingTimeInterval:self.pollInterval];
		NSDate *now = [NSDate date];
		if ([[threshold earlierDate:now] isEqualToDate:now]) {
			return [super cachePolicy];
		} else {
			return NSURLRequestReloadIgnoringLocalCacheData;
		}
	} else {
		return NSURLRequestReloadIgnoringLocalCacheData;
	}
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (id dict in values) {
		GHNotification *notification = [[GHNotification alloc] initWithDict:dict];
		[self addObject:notification];
	}
	[self rebuildCache];
	self.lastUpdate = [NSDate date];
	[IOCDefaultsPersistence setLastUpate:self.lastUpdate forPath:self.resourcePath];
}

- (void)setHeaderValues:(NSDictionary *)values {
	[super setHeaderValues:values];
	NSInteger interval = [values safeIntegerForKey:@"X-Poll-Interval"];
	if (interval) self.pollInterval = interval;
}

- (void)rebuildCache {
	self.notificationsCount = self.count;
	self.byRepository = [NSMutableDictionary dictionary];
	for (GHNotification *notification in self.items) {
		if (!self.byRepository[notification.repository.repoId]) {
			self.byRepository[notification.repository.repoId] = [NSMutableArray array];
		}
		[self.byRepository[notification.repository.repoId] addObject:notification];
	}
}

- (void)markAsRead:(GHNotification *)notification success:(resourceSuccess)success failure:(resourceFailure)failure {
	[notification markAsReadSuccess:^(GHResource *notification, id response) {
		[self removeObject:notification];
		[self rebuildCache];
		if (success) success(notification, response);
	} failure:^(GHResource *notification, NSError *error) {
		if (failure) failure(notification, error);
	}];

}

- (void)markAllAsReadSuccess:(resourceSuccess)success failure:(resourceFailure)failure {
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil) dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
	NSString *lastReadAt = [[dateFormatter stringFromDate:self.lastUpdate] stringByAppendingString:@"Z"];
	NSDictionary *params = @{@"read": @YES, @"last_read_at": lastReadAt};
	[self saveWithParams:params path:self.resourcePath method:kRequestMethodPut success:^(GHResource *notifications, id response) {
		[self setValues:@[]];
		if (success) success(notifications, response);
	} failure:^(GHResource *notifications, NSError *error) {
		if (failure) failure(notifications, error);
	}];
}

@end