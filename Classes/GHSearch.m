#import "GHSearch.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"
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
	NSArray *objects = [dict ioc_arrayForKey:@"users"];
	BOOL usersSearch = objects ? YES : NO;
	if (!objects) objects = [dict ioc_arrayForKey:@"repositories"];
	for (NSDictionary *dict in objects) {
		GHResource *resource = nil;
		if (usersSearch) {
			NSString *login = [dict ioc_stringForKey:@"login"];
			resource = [iOctocat.sharedInstance userWithLogin:login];
			[resource setValues:dict];
		} else {
			NSString *owner = [dict ioc_stringForKey:@"owner"];
			NSString *name = [dict ioc_stringForKey:@"name"];
			resource = [[GHRepository alloc] initWithOwner:owner andName:name];
			[resource setValues:dict];
		}
		[self addObject:resource];
	}
}

@end