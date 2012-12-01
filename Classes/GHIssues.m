#import "GHIssues.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHIssues

+ (id)issuesWithResourcePath:(NSString *)thePath {
	return [[[self.class alloc] initWithResourcePath:thePath] autorelease];
}

+ (id)issuesWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
	return [[[self.class alloc] initWithRepository:theRepository andState:theState] autorelease];
}

- (id)initWithResourcePath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)theRepository andState:(NSString *)theState {
	NSString *path = [NSString stringWithFormat:kIssuesFormat, theRepository.owner, theRepository.name, theState];
	self = [self initWithResourcePath:path];
	if (self) {
		self.repository = theRepository;
		self.issueState = theState;
	}
	return self;
}

- (void)dealloc {
	[_repository release], _repository = nil;
	[_issueState release], _issueState = nil;
	[_entries release], _entries = nil;
	[super dealloc];
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHIssue *theIssue = [GHIssue issueWithRepository:self.repository];
		[theIssue setValues:dict];
		[resources addObject:theIssue];
	}
	self.entries = resources;
}

@end