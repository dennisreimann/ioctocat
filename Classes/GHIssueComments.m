#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
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
	NSString *urlString = [NSString stringWithFormat:kIssueCommentsJSONFormat, issue.repository.owner, issue.repository.name, issue.num];
	return [NSURL URLWithString:urlString];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssueComments issue:'%@'>", issue];
}

- (void)parseData:(NSData *)theData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserialize:theData error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in [resultDict objectForKey:@"comments"]) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithIssue:issue andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(parsingFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotProcessed;
	} else {
		self.comments = theResult;
		self.loadingStatus = GHResourceStatusProcessed;
	}
}

@end
