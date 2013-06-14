#import "GHPullRequestReviewComments.h"
#import "GHPullRequestReviewComment.h"
#import "GHPullRequest.h"
#import "GHRepository.h"


@interface GHPullRequestReviewComments ()
@property(nonatomic,weak)GHPullRequest *parent;
@end

@implementation GHPullRequestReviewComments

- (id)initWithParent:(id)parent {
	self = [super init];
	if (self) {
		self.parent = parent;
	}
	return self;
}

// Dynamic resourcePath, because it depends on the issue num which isn't always available in advance
- (NSString *)resourcePath {
	return [NSString stringWithFormat:kGHPullRequestCommentsFormat, self.parent.repository.owner, self.parent.repository.name, self.parent.number];
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
		GHPullRequestReviewComment *comment = [[GHPullRequestReviewComment alloc] initWithParent:self.parent];
		[comment setValues:dict];
		[self addObject:comment];
	}
}

@end