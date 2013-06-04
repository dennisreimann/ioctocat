#import "GHEvents.h"
#import "GHEvent.h"
#import "GHRepository.h"
#import "IOCDefaultsPersistence.h"


@implementation GHEvents

@synthesize resourcePath = _resourcePath;

- (id)initWithPath:(NSString *)path account:(GHAccount *)account {
	self = [super initWithPath:path];
	if (self) {
		self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:path account:account];
        self.lastRead = [IOCDefaultsPersistence lastReadForPath:path account:account];
        if (!self.lastRead) self.lastRead = self.lastUpdate;
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoEventsFormat, repo.owner, repo.name];
	return [self initWithPath:path];
}

- (void)setResourcePath:(NSString *)path {
	_resourcePath = path;
	self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:self.resourcePath account:self.account];
    self.lastRead = [IOCDefaultsPersistence lastReadForPath:self.resourcePath account:self.account];
    if (!self.lastRead) self.lastRead = self.lastUpdate;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHEvent *event = [[GHEvent alloc] initWithDict:dict];
		if (self.lastRead && [event.date compare:self.lastRead] != NSOrderedDescending) {
			[event markAsRead];
		}
		[self addObject:event];
	}
	self.lastUpdate = [NSDate date];
	[IOCDefaultsPersistence setLastUpate:self.lastUpdate forPath:self.resourcePath account:self.account];
}

- (void)markAllAsRead {
    for (GHEvent *event in self.items) {
		 [event markAsRead];
    }
    self.lastRead = self.lastUpdate;
	[IOCDefaultsPersistence setLastRead:self.lastRead forPath:self.resourcePath account:self.account];
}

@end