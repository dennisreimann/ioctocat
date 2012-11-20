#import "GHIssues.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHIssues

@synthesize entries;
@synthesize repository;
@synthesize issueState;


+ (id)issuesWithResourcePath:(NSString *)thePath {
	return [[[self.class alloc] initWithResourcePath:thePath] autorelease];
}

+ (id)issuesWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
	return [[[self.class alloc] initWithRepository:theRepository andState:theState] autorelease];
}

- (id)initWithResourcePath:(NSString *)thePath {
	[super init];
	self.resourcePath = thePath;
	return self;
}

- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
	NSString *path = [NSString stringWithFormat:kIssuesFormat, theRepository.owner, theRepository.name, theState];
	[self initWithResourcePath:path];
	self.repository = theRepository;
	self.issueState = theState;
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

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHIssue *theIssue = [GHIssue issueWithRepository:repository];
		[theIssue setValues:dict];
		[resources addObject:theIssue];
	}
	self.entries = resources;
}

@end