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

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// issue num which isn't always available in advance
	GHRepository *repo = self.parent.repository;
	NSUInteger num = self.parent.number;
	return [NSString stringWithFormat:kGHPullRequestCommentsFormat, repo.owner, repo.name, num];
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