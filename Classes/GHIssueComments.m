#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHIssueComments

@synthesize comments;
@synthesize parent;

+ (id)commentsWithParent:(id)theParent {
	return [[[[self class] alloc] initWithParent:theParent] autorelease];
}

- (id)initWithParent:(id)theParent {
	[super init];
	self.parent = theParent;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[parent release], parent = nil;
	[super dealloc];
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// issue num which isn't always available in advance
	GHRepository *repo = [(GHIssue *)parent repository];
	NSUInteger num = [(GHIssue *)parent num];
	return [NSString stringWithFormat:kIssueCommentsFormat, repo.owner, repo.name, num];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHIssueComments parent:'%@'>", parent];
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHIssueComment *comment = [GHIssueComment commentWithParent:parent andDictionary:dict];
		[resources addObject:comment];
	}
	self.comments = resources;
}

@end