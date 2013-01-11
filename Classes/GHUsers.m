#import "GHUsers.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@implementation GHUsers

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		NSString *login = [dict safeStringForKey:@"login"];
		GHUser *user = [[iOctocat sharedInstance] userWithLogin:login];
		[user setValues:dict];
		[self addObject:user];
	}
	[self.items sortUsingSelector:@selector(compareByName:)];
}

@end