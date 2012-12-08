#import "GHGists.h"
#import "GHGist.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHGists

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
		self.gists = [NSMutableArray array];
	}
	return self;
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHGist *resource = [[GHGist alloc] initWithId:[dict valueForKey:@"id"]];
		[resource setValues:dict];
		[resources addObject:resource];
	}
	self.gists = resources;
}

@end