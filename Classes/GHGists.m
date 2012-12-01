#import "GHGists.h"
#import "GHGist.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation GHGists

+ (id)gistsWithPath:(NSString *)thePath {
	return [[[self.class alloc] initWithPath:thePath ] autorelease];
}

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
		self.gists = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[_gists release], _gists = nil;
	[super dealloc];
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHGist *resource = [GHGist gistWithId:[dict valueForKey:@"id"]];
		[resource setValues:dict];
		[resources addObject:resource];
	}
	self.gists = resources;
}

@end