#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHIssueComments

@synthesize comments;
@synthesize issue;

+ (id)commentsWithIssue:(GHIssue *)theIssue {
	return [[[[self class] alloc] initWithIssue:theIssue] autorelease];
}

- (id)initWithIssue:(GHIssue *)theIssue {
	[super init];
	self.issue = theIssue;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[issue release], issue = nil;
	[super dealloc];
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// issue num which isn't always available in advance
	return [NSString stringWithFormat:kIssueCommentsFormat, issue.repository.owner, issue.repository.name, issue.num];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssueComments issue:'%@'>", issue];
}

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithIssue:issue andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    self.comments = resources;
}

@end
