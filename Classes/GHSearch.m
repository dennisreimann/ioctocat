#import "GHSearch.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHSearch

+ (id)searchWithURLFormat:(NSString *)theFormat {
	return [[[self.class alloc] initWithURLFormat:theFormat] autorelease];
}

- (id)initWithURLFormat:(NSString *)theFormat {
	self = [super init];
	self.urlFormat = [theFormat retain];
	return self;
}

- (void)dealloc {
	[_searchTerm release], _searchTerm = nil;
	[_urlFormat release], _urlFormat = nil;
	[_results release], _results = nil;
	[super dealloc];
}

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// searchTerm which isn't always available in advance
	NSString *encodedSearchTerm = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *path = [NSString stringWithFormat:self.urlFormat, encodedSearchTerm];
	return path;
}

- (void)setValues:(NSDictionary *)theDict {
	BOOL usersSearch = [theDict objectForKey:@"users"] ? YES : NO;
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in (usersSearch ? [theDict objectForKey:@"users"] : [theDict objectForKey:@"repositories"])) {
		GHResource *resource = nil;
		if (usersSearch) {
			resource = [GHUser userWithLogin:[dict objectForKey:@"login"]];
			[resource setValues:dict];
		} else {
			resource = [GHRepository repositoryWithOwner:[dict objectForKey:@"owner"] andName:[dict objectForKey:@"name"]];
			[resource setValues:dict];
		}
		[resources addObject:resource];
	}
	self.results = resources;
}

@end