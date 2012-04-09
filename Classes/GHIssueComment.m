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
	NSString *createdAt = [theDict valueForKey:@"created_at"];
	NSString *updatedAt = [theDict valueForKey:@"updated_at"];
	
	self.body = [theDict valueForKey:@"body"];
	self.user = [[iOctocat sharedInstance] userWithLogin:[theDict valueForKeyPath:@"user.login"]];
	self.created = [iOctocat parseDate:createdAt];
	self.updated = [iOctocat parseDate:updatedAt];
	
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
	NSDictionary *values = [NSDictionary dictionaryWithObject:body forKey:@"body"];
	NSURL *saveURL = [NSURL URLWithFormat:kIssueCommentsFormat, issue.repository.owner, issue.repository.name, issue.num];
	[self saveValues:values withURL:saveURL andMethod:@"POST"];
}

@end
