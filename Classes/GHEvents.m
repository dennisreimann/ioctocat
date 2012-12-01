#import "GHEvents.h"
#import "GHEvent.h"
#import "GHRepository.h"


@implementation GHEvents

+ (id)eventsWithRepository:(GHRepository *)theRepo {
	NSString *path = [NSString stringWithFormat:kRepoEventsFormat, theRepo.owner, theRepo.name];
	return [super resourceWithPath:path];
}

- (void)dealloc {
	[_lastReadingDate release], _lastReadingDate = nil;
	[_events release], _events = nil;
	[super dealloc];
}

- (void)setValues:(id)theDicts {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theDicts) {
		GHEvent *event = [GHEvent eventWithDict:dict];
		if ([event.date compare:self.lastReadingDate] != NSOrderedDescending) event.read = YES;
		[resources addObject:event];
	}
	self.events = resources;
	self.lastReadingDate = [NSDate date];
}

@end