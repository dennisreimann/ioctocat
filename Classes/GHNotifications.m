#import "GHNotifications.h"
#import "GHNotification.h"
#import "NSDictionary+Extensions.h"


@implementation GHNotifications

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (id dict in values) {
		GHNotification *resource = [[GHNotification alloc] initWithId:[dict safeStringForKey:@"id"]];
		[resource setValues:dict];
		[self addObject:resource];
	}
}

@end