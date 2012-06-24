#import "GHIssues.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


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
	self.resourcePath = [NSString stringWithFormat:kIssuesFormat, repository.owner, repository.name, issueState];	
	
	return self;    
}

- (void)dealloc {
	[repository release], repository = nil;
	[issueState release], issueState = nil;
	[entries release], entries = nil;
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssues repository:'%@' state:'%@'>", repository, issueState];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theDict) {
		GHIssue *theIssue = [GHIssue issueWithRepository:repository];
    	[theIssue setValuesFromDict:dict];
    	[resources addObject:theIssue];
	}
	self.entries = resources;
}

@end
