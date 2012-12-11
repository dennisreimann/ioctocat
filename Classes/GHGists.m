#import "GHGists.h"
#import "GHGist.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHGists

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
	}
	return self;
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHGist *resource = [[GHGist alloc] initWithId:[dict valueForKey:@"id"]];
		[resource setValues:dict];
		[self addObject:resource];
	}
}

@end