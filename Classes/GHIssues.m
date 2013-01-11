#import "GHIssues.h"
#import "GHIssue.h"
#import "GHRepository.h"


@implementation GHIssues

- (id)initWithResourcePath:(NSString *)path {
	self = [super init];
	if (self) {
		self.resourcePath = path;
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo andState:(NSString *)state {
	NSString *path = [NSString stringWithFormat:kIssuesFormat, repo.owner, repo.name, state];
	self = [self initWithResourcePath:path];
	if (self) {
		self.repository = repo;
		self.issueState = state;
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