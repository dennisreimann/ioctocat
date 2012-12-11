#import "GHIssues.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHIssues

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

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
		[issue setValues:dict];
		[self addObject:issue];
	}
}

@end