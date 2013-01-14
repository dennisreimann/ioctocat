#import "AFHTTPRequestOperation.h"
#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"
#import "IOCDefaultsPersistence.h"


@implementation GHNotifications

- (id)initWithPath:(NSString *)path {
	if (self = [super initWithPath:path]) {
		self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:self.resourcePath];
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	self.byRepository = [NSMutableDictionary dictionary];
	for (id dict in values) {
		GHNotification *notification = [[GHNotification alloc] initWithDict:dict];
		[self addObject:notification];
		if (!self.byRepository[notification.repository.repoId]) {
			self.byRepository[notification.repository.repoId] = [NSMutableArray array];
		}
		[self.byRepository[notification.repository.repoId] addObject:notification];
	}
	self.lastUpdate = [NSDate date];
	[IOCDefaultsPersistence setLastUpate:self.lastUpdate forPath:self.resourcePath];
}

- (void)setHeaderValues:(NSDictionary *)values {
	[super setHeaderValues:values];
	NSInteger interval = [values safeIntegerForKey:@"X-Poll-Interval"];
	if (interval) self.pollInterval = interval;
}

- (void)markAllAsRead {
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil) dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
	NSString *lastReadAt = [[dateFormatter stringFromDate:self.lastUpdate] stringByAppendingString:@"Z"];
	NSDictionary *values = @{@"read": @YES, @"last_read_at": lastReadAt};
	[self saveValues:values withPath:self.resourcePath andMethod:kRequestMethodPut useResult:^(id response) {
		[self setHeaderValues:values];
		// empty out the current notifications and refresh
		[self setValues:@[]];
		[self loadData];
	}];
}

@end