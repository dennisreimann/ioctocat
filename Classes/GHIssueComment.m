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

- (void)saveComment {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusSaving;
	[self performSelectorInBackground:@selector(sendCommentData) withObject:nil];
}

- (void)sendCommentData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *urlString = [NSString stringWithFormat:kIssueCommentJSONFormat, issue.repository.owner, issue.repository.name, issue.num];
	NSURL *saveURL = [NSURL URLWithString:urlString];
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:saveURL];
	[request setPostValue:body forKey:kIssueCommentCommentParamName];
	[request start];
	NSError *parseError = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
	id res = parseError ? (id)parseError : (id)resultDict;
	[self performSelectorOnMainThread:@selector(processResult:) withObject:res waitUntilDone:YES];
	[pool release];
}

- (void)processResult:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.savingStatus = GHResourceStatusNotSaved;
	} else {
		// NSString *status = [[theResult objectForKey:@"comment"] objectForKey:@"status"];
		self.savingStatus = GHResourceStatusSaved;
	}
}

@end
