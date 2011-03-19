#import "GHIssueComment.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


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
	NSURL *saveURL = [NSURL URLWithFormat:kIssueCommentFormat, issue.repository.owner, issue.repository.name, issue.num];
	[self saveValues:values withURL:saveURL];
}

@end
