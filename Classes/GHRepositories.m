#import "GHRepositories.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "ASIFormDataRequest.h"


@implementation GHRepositories

@synthesize repositories;

+ (id)repositoriesWithURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
    [super init];
    self.resourceURL = theURL;
	self.repositories = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[repositories release], repositories = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepositories resourceURL:'%@'>", resourceURL];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in [theDict objectForKey:@"repositories"]) {
		GHRepository *resource = [GHRepository repositoryWithOwner:[dict objectForKey:@"owner"] andName:[dict objectForKey:@"name"]];
        [resource setValuesFromDict:dict];
        [resources addObject:resource];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.repositories = resources;
}

@end
