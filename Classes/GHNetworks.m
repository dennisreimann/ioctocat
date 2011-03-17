#import "GHNetworks.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"

@implementation GHNetworks

@synthesize entries;
@synthesize repository;

+ (id)networksWithRepository:(GHRepository *)theRepository {
	return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
    [super init];
    self.repository = theRepository;
	NSString *urlString = [NSString stringWithFormat:kRepoNetworkFormat, repository.owner, repository.name];
	self.resourceURL = [NSURL URLWithString:urlString];
	return self;    
}

- (void)dealloc {
	[repository release], repository = nil;
	[entries release], entries = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHNetworks repository:'%@'>", repository];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in [theDict objectForKey:@"network"]) {
		GHRepository *resource = [GHRepository repositoryWithOwner:[dict objectForKey:@"owner"] andName:[dict objectForKey:@"name"]];
        [resource setValuesFromDict:dict];
        [resources addObject:resource];
    }
    [resources sortUsingSelector:@selector(compareByName:)];
    self.entries = resources;
}

@end
