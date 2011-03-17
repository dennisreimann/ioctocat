#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"


@implementation GHIssueComment

@synthesize issue;
@synthesize user;
@synthesize commentID;
@synthesize body;
@synthesize created;
@synthesize updated;

- (id)initWithIssue:(GHIssue *)theIssue andDictionary:(NSDictionary *)theDict {
	[self initWithIssue:theIssue];	
	
	// Dates
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z";
	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKey:@"user"]];
	self.body = [theDict valueForKey:@"body"];
	self.created = [dateFormatter dateFromString:createdAt];
	self.updated = [dateFormatter dateFromString:updatedAt];
	
	[dateFormatter release];
	
	return self;
}

- (id)initWithIssue:(GHIssue *)theIssue {
	[super init];
	self.issue = theIssue;
	return self;
}

- (void)dealloc {
	[issue release], issue = nil;
	[user release], user = nil;
	[body release], body = nil;
	[created release], created = nil;
	[updated release], updated = nil;
	
	[super dealloc];
}

#pragma mark Saving

- (void)saveData {
	NSDictionary *values = [NSDictionary dictionaryWithObject:body forKey:kIssueCommentCommentParamName];
	NSString *urlString = [NSString stringWithFormat:kIssueCommentFormat, issue.repository.owner, issue.repository.name, issue.num];
	NSURL *saveURL = [NSURL URLWithString:urlString];
	[self saveValues:values withURL:saveURL];
}

- (void)parseSaveData:(NSData *)theData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserialize:theData error:&parseError];
	id res = parseError ? (id)parseError : (id)resultDict;
	[self performSelectorOnMainThread:@selector(parsingSaveFinished:) withObject:res waitUntilDone:YES];
	[pool release];
}

- (void)parsingSaveFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotProcessed;
	} else {
		self.savingStatus = GHResourceStatusProcessed;
	}
}

@end
