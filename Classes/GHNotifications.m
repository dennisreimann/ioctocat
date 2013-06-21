#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"
#import "IOCDefaultsPersistence.h"


@interface GHNotifications ()
@property(nonatomic,readwrite)NSInteger unreadCount;
@end


@implementation GHNotifications

- (id)initWithPath:(NSString *)path {
	if (self = [super initWithPath:path]) {
		self.unreadCount = 0;
		self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:self.resourcePath account:self.account];
	}
	return self;
}

// If there is a polling interval given by GitHub respect it:
// Only reload in case the last update has passed the interval
- (BOOL)canReload {
	if (self.pollInterval) {
		NSDate *threshold = [self.lastUpdate dateByAddingTimeInterval:self.pollInterval];
		NSDate *now = [NSDate date];
		return [[threshold earlierDate:now] isEqualToDate:threshold];
	} else {
		return YES;
	}
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (id dict in values) {
		GHNotification *notification = [[GHNotification alloc] initWithDict:dict];
		[self addObject:notification];
	}
	[self updateUnreadCount];
	self.lastUpdate = [NSDate date];
	[IOCDefaultsPersistence setLastUpate:self.lastUpdate forPath:self.resourcePath account:self.account];
}

- (void)setHeaderValues:(NSDictionary *)values {
	[super setHeaderValues:values];
	self.pollInterval = [values ioc_integerForKey:@"X-Poll-Interval"];
}

- (void)markAsRead:(GHNotification *)notification start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[notification markAsReadStart:^(GHResource *notification) {
		if (start) start(self);
	} success:^(GHResource *notification, id response) {
		[self updateUnreadCount];
		if (success) success(self, response);
	} failure:^(GHResource *notification, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)markAllAsReadStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSDictionary *params = @{@"read": @YES, @"last_read_at": self.formattedLastReadAt};
	[self saveWithParams:params path:self.resourcePath method:kRequestMethodPut start:start success:^(GHResource *notifications, id response) {
		[self setValues:@[]];
		if (success) success(self, response);
	} failure:^(GHResource *notifications, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)markAllAsReadForRepoId:(NSString *)repoId start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSString *path = [NSString stringWithFormat:kRepoNotificationsFormat, repoId];
	NSDictionary *params = @{@"read": @YES, @"last_read_at": self.formattedLastReadAt};
	[self saveWithParams:params path:path method:kRequestMethodPut start:start success:^(GHResource *notifications, id response) {
		NSIndexSet *indexSet = [self.items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			GHRepository *repo = [(GHNotification *)obj repository];
			return [repo.repoId isEqualToString:repoId];
		}];
		[self.items removeObjectsAtIndexes:indexSet];
		[self updateUnreadCount];
		if (success) success(self, response);
	} failure:^(GHResource *notifications, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)updateUnreadCount {
	NSIndexSet *unreadIndexes = [self.items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return ![(GHNotification *)obj read];
	}];
	self.unreadCount = unreadIndexes.count;
}

- (NSString *)formattedLastReadAt {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
	NSString *lastReadAt = [[dateFormatter stringFromDate:self.lastUpdate] stringByAppendingString:@"Z"];
	return lastReadAt;
}

@end