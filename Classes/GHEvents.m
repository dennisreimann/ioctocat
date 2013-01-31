#import "GHEvents.h"
#import "GHEvent.h"
#import "GHRepository.h"
#import "IOCDefaultsPersistence.h"


@implementation GHEvents

- (id)initWithPath:(NSString *)path {
	if (self = [super initWithPath:path]) {
		self.lastUpdate = [IOCDefaultsPersistence lastUpdateForPath:self.resourcePath];
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kRepoEventsFormat, repo.owner, repo.name];
	return [self initWithPath:path];
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHEvent *event = [[GHEvent alloc] initWithDict:dict];
		if ([event.date compare:self.lastUpdate] != NSOrderedDescending) {
			[event markAsRead];
		}
		[self addObject:event];
	}
	self.lastUpdate = [NSDate date];
	[IOCDefaultsPersistence setLastUpate:self.lastUpdate forPath:self.resourcePath];
}

@end