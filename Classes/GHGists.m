#import "GHGists.h"
#import "GHGist.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHGists

- (void)setValues:(id)values {
    [super setValues:values];
	for (id dict in values) {
		if ([dict isKindOfClass:NSDictionary.class]) {
			GHGist *resource = [[GHGist alloc] initWithId:[dict ioc_stringForKey:@"id"]];
			[resource setValues:dict];
			[self addObject:resource];
		} else {
			DJLog(@"Could not add gist: Expected a dictionary but got %@", dict);
		}
	}
}

@end