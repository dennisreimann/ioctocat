#import "GHSearch.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"


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
	NSString *encodedSearchTerm = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *path = [NSString stringWithFormat:self.urlFormat, encodedSearchTerm];
	return path;
}

- (void)setValues:(NSDictionary *)dict {
    [super setValues:dict];
	NSArray *objects = [dict safeArrayForKey:@"users"];
	BOOL usersSearch = objects ? YES : NO;
	if (!objects) objects = [dict safeArrayForKey:@"repositories"];
	for (NSDictionary *dict in objects) {
		GHResource *resource = nil;
		if (usersSearch) {
			NSString *login = [dict safeStringForKey:@"login"];
			resource = [iOctocat.sharedInstance userWithLogin:login];
			[resource setValues:dict];
		} else {
			NSString *owner = [dict safeStringForKey:@"owner"];
			NSString *name = [dict safeStringForKey:@"name"];
			resource = [[GHRepository alloc] initWithOwner:owner andName:name];
			[resource setValues:dict];
		}
		[self addObject:resource];
	}
}

@end