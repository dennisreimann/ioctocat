#import "GHIssues.h"
#import "GHUser.h"


@implementation GHIssues

@synthesize entries;
@synthesize repository;
@synthesize issueState;

+ (id)issuesWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
	return [[[[self class] alloc] initWithRepository:theRepository andState:theState] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
    [super init];
    self.repository = theRepository;
    self.issueState = theState;
	NSString *urlString = [NSString stringWithFormat:kIssuesFormat, repository.owner, repository.name, issueState];
	self.resourceURL = [NSURL URLWithString:urlString];	
	
	return self;    
}

- (void)dealloc {
	[repository release];
	[issueState release];
	[entries release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssues repository:'%@' state:'%@'>", repository, issueState];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in [theDict objectForKey:@"issues"]) {
		GHIssue *theIssue = [GHIssue issueWithRepository:repository];
        [theIssue setValuesFromDict:dict];
        [resources addObject:theIssue];
    }
    self.entries = resources;
}

@end
