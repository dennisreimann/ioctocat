#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHIssueComments

+ (id)commentsWithParent:(id)theParent {
	return [[self.class alloc] initWithParent:theParent];
}

- (id)initWithParent:(id)theParent {
	self = [super init];
	if (self) {
		self.parent = theParent;
		self.comments = [NSMutableArray array];
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

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHIssueComment *comment = [GHIssueComment commentWithParent:self.parent andDictionary:dict];
		[resources addObject:comment];
	}
	self.comments = resources;
}

@end