#import "GHGists.h"
#import "GHGist.h"
#import "NSDictionary+Extensions.h"


@implementation GHGists

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (id dict in values) {
		if ([dict isKindOfClass:NSDictionary.class]) {
			GHGist *resource = [[GHGist alloc] initWithId:[dict safeStringForKey:@"id"]];
			[resource setValues:dict];
			[self addObject:resource];
		} else {
			DJLog(@"Could not add gist: Expected a dictionary but got %@", dict);
		}
	}
}

@end