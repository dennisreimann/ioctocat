#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


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

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// issue num which isn't always available in advance
	NSString *urlString = [NSString stringWithFormat:kIssueCommentsFormat, issue.repository.owner, issue.repository.name, issue.num];
	return [NSURL URLWithString:urlString];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssueComments issue:'%@'>", issue];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in [theDict objectForKey:@"comments"]) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithIssue:issue andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    self.comments = resources;
}

@end
