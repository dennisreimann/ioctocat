#import "GHSearch.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHSearch ()
@property(nonatomic,strong)NSMutableArray *results;
@property(nonatomic,strong)NSString *urlFormat;
@end


@implementation GHSearch

- (id)initWithURLFormat:(NSString *)format {
	self = [super init];
	if (self) {
		self.urlFormat = format;
	}
	return self;
}

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// searchTerm which isn't always available in advance
	NSString *encodedSearchTerm = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *path = [NSString stringWithFormat:self.urlFormat, encodedSearchTerm];
	return path;
}

- (NSArray *)searchResults {
	return self.results;
}

- (BOOL)isEmpty {
	return !self.results || self.results.count == 0;
}

- (void)setValues:(NSDictionary *)dict {
	NSArray *objects = [dict safeArrayForKey:@"users"];
	BOOL usersSearch = objects ? YES : NO;
	if (!objects) objects = [dict safeArrayForKey:@"repositories"];
	self.results = [NSMutableArray array];
	for (NSDictionary *dict in objects) {
		GHResource *resource = nil;
		if (usersSearch) {
			resource = [[GHUser alloc] initWithLogin:dict[@"login"]];
			[resource setValues:dict];
		} else {
			resource = [[GHRepository alloc] initWithOwner:dict[@"owner"] andName:dict[@"name"]];
			[resource setValues:dict];
		}
		[self.results addObject:resource];
	}
}

@end