#import "GHSearch.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHSearch

@synthesize results;
@synthesize searchTerm;

+ (id)searchWithURLFormat:(NSString *)theFormat {
	return [[[self.class alloc] initWithURLFormat:theFormat] autorelease];
}

- (id)initWithURLFormat:(NSString *)theFormat {
	[super init];
	urlFormat = [theFormat retain];
	return self;
}

- (void)dealloc {
	[searchTerm release], searchTerm = nil;
	[urlFormat release], urlFormat = nil;
	[results release], results = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHSearch searchTerm:'%@' resourcePath:'%@'>", searchTerm, self.resourcePath];
}

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// searchTerm which isn't always available in advance
	NSString *encodedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *path = [NSString stringWithFormat:urlFormat, encodedSearchTerm];
	return path;
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    BOOL usersSearch = [theDict objectForKey:@"users"] ? YES : NO;
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in (usersSearch ? [theDict objectForKey:@"users"] : [theDict objectForKey:@"repositories"])) {
        GHResource *resource = nil;
        if (usersSearch) {
            resource = [GHUser userWithLogin:[dict objectForKey:@"login"]];
            [resource setValuesFromDict:dict];
        } else {
            resource = [GHRepository repositoryWithOwner:[dict objectForKey:@"owner"] andName:[dict objectForKey:@"name"]];
            [resource setValuesFromDict:dict];
        }
        [resources addObject:resource];
    }
    self.results = resources;
}

@end
