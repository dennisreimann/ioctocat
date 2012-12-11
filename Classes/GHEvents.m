#import "GHEvents.h"
#import "GHEvent.h"
#import "GHRepository.h"


@implementation GHEvents

- (id)initWithRepository:(GHRepository *)theRepo {
	NSString *path = [NSString stringWithFormat:kRepoEventsFormat, theRepo.owner, theRepo.name];
	return [super initWithPath:path];
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHEvent *event = [[GHEvent alloc] initWithDict:dict];
		if ([event.date compare:self.lastReadingDate] != NSOrderedDescending) event.read = YES;
		[self addObject:event];
	}
	self.lastReadingDate = [NSDate date];
}

@end