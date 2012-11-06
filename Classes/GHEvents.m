#import "GHEvents.h"
#import "GHEvent.h"
#import "GHRepository.h"


@implementation GHEvents

@synthesize events;
@synthesize lastReadingDate;

+ (id)eventsWithRepository:(GHRepository *)theRepo {
	NSString *path = [NSString stringWithFormat:kRepoEventsFormat, theRepo.owner, theRepo.name];
	return [super resourceWithPath:path];
}

- (void)dealloc {
	[events release], events = nil;
	[lastReadingDate release], lastReadingDate = nil;
    [super dealloc];
}

- (void)setValues:(id)theDicts {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theDicts) {
		GHEvent *event = [GHEvent eventWithDict:dict];
		if ([event.date compare:lastReadingDate] != NSOrderedDescending) event.read = YES;
		[resources addObject:event];
	}
	self.events = resources;
	self.lastReadingDate = [NSDate date];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHEvents resourcePath:'%@'>", resourcePath];
}

@end
