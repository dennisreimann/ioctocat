#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"


@interface GHIssueComments ()
@property(nonatomic,weak)id parent; // a GHIssue or GHPullRequest instance
@end

@implementation GHIssueComments

- (id)initWithParent:(id)parent {
	self = [super init];
	if (self) {
		self.parent = parent;
	}
	return self;
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// issue num which isn't always available in advance
	GHRepository *repo = [(GHIssue *)self.parent repository];
	NSUInteger num = [(GHIssue *)self.parent num];
	return [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.parent];
		[comment setValues:dict];
		[self addObject:comment];
	}
}

@end