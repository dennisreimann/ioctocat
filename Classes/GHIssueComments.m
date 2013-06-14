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

// Dynamic resourcePath, because it depends on the issue num which isn't always available in advance
- (NSString *)resourcePath {
	GHRepository *repo = [(GHIssue *)self.parent repository];
	NSUInteger num = [(GHIssue *)self.parent number];
	return [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.parent];
		[comment setValues:dict];
		[self addObject:comment];
	}
}

@end